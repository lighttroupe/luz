 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

require 'glade_window', 'event_combobox', 'tag_treeview'

class UserObjectPropertiesEditorWindow < GladeWindow
	callback :objects_changed
	callback :objects_tagged

	def initialize(tag_model=nil)
		super()

		on_key_press(Gdk::Keyval::GDK_Escape) { hide }

		on_key_press(Gdk::Keyval::GDK_Return) {
			hide if @title_entry.has_focus?
			@add_tag_button.activate if @tag_entry.has_focus?
			hide if @tag_entry.has_focus? && @tag_entry.text == ''
		}

		@objects = []

		# incompatible with comboboxes: on_lose_focus { hide }	# NOTE: This doesn't work if the dialog has widgets that create subwindows, like comboboxes

		@event_combobox = EventComboBox.new
		@event_combobox.parent = @event_combobox_container

		# Event conditions
		@enable_event_condition_checkbox.on_change_with_init {
			@event_condition_controls_container.sensitive = ($settings['live-editing'] or @enable_event_condition_checkbox.active?)
			update_objects
			objects_changed_notify
		}
		@event_combobox.on_change {
			update_objects
			objects_changed_notify
		}
		@event_on_radiobutton.on_change {
			update_objects
			objects_changed_notify
		}

		# Child conditions
		@enable_child_index_range_checkbox.on_change_with_init {
			@child_index_range_controls_container.sensitive = ($settings['live-editing'] or @enable_child_index_range_checkbox.active?)
			update_objects
			objects_changed_notify
		}
		@child_index_min_spinbutton.on_change {
			# don't allow min to go above max
			@child_index_max_spinbutton.value = @child_index_min_spinbutton.value if (@child_index_min_spinbutton.value > @child_index_max_spinbutton.value)

			update_objects
			objects_changed_notify
		}
		@child_index_max_spinbutton.on_change {
			# don't allow max to go below min
			@child_index_min_spinbutton.value = @child_index_max_spinbutton.value if (@child_index_max_spinbutton.value < @child_index_min_spinbutton.value)

			update_objects
			objects_changed_notify
		}

		if tag_model
			@tag_treeview = TagTreeView.new(tag_model).show
			@tag_treeview_container.add(@tag_treeview)

			# Add "entry completion" to help user by matching what they type against existing tags
			@tag_entry_completion = Gtk::EntryCompletion.new.set_model(tag_model).set_text_column(tag_model.class.name_column_index)
			@tag_entry.set_completion(@tag_entry_completion)

			# Set up our own callbacks for setting the model's checkbox
			@tag_treeview.model.on_is_activated(&method(:tag_is_activated?))
			@tag_treeview.model.on_is_inconsistent(&method(:tag_is_inconsistent?))
			@tag_treeview.on_toggled { |iter|
				tag = @tag_treeview.model.get_object_column(iter)
				if tag_is_activated?(tag)
					remove_tag_from_objects(tag)
				else
					add_tag_to_objects(tag)
				end
				@tag_treeview.model.set_columns_from_object(iter)

				# Notify parent
				objects_tagged_notify(@objects)
				objects_changed_notify(@objects)
		}
		else
			@tags_container.hide
		end
	end

	def add_tag_to_objects(tag)
		@objects.each { |object| object.add_tag(tag) }

		# Hack to notify tagging module of change (so it can update its internal object list for this tag)
		$engine.project.update_tags_for_object_class(@objects.first.class.taggable_base_class)
	end

	def remove_tag_from_objects(tag)
		@objects.each { |object| object.remove_tag(tag) }
	end

	def tag_is_activated?(tag)
		return (@objects and @objects.all? { |object| object.has_tag?(tag) })
	end

	def tag_is_inconsistent?(tag)
		return (@objects and @objects.inconsistent? { |object| object.has_tag?(tag) })
	end

	def on_add_tags_button_clicked
		# Allow multiple comma separated tags
		@tag_entry.text.split(',').each { |tag|
			tag.strip!
			next if tag.empty?

			add_tag_to_objects(tag)		# NOTE: add to objects before treeview so it shows up checked
			@tag_treeview.select(@tag_treeview.model.add_or_update_object(tag))
		}
		objects_tagged_notify(@objects)
		objects_changed_notify(@objects)

		@tag_entry.text = ''
		@tag_entry.grab_focus
	end


	def update_window_title
		if @objects.size == 1
			if(@objects.first.title.empty?)
				self.title = "Object Properties"
			else
				self.title = "#{@objects.first.title} Properties"
			end
		else
			self.title = "Editing #{@objects.size} object(s)"
		end
	end

	def show_for(objects)
		@setting_values = true

		@objects = objects
		if @objects.collect { |o| o.class.title }.uniq.size == 1
			@object_type_label.markup = @objects.first.class.title
		else
			@object_type_label.markup = '<i>multiple</i>'
		end
		update_window_title

		@title_entry.text = @objects.all_equal_or_default(:title, '')

		#
		# Environment
		#
		if objects.first.respond_to?(:conditions)
			@conditions_container.visible = true
			conditions = @objects.collect { |o| o.conditions }

			# TODO: this container is poorly named, it should be about environment conditions
			@child_conditions_container.visible = conditions.first.respond_to?(:enable_event)

			if @child_conditions_container.visible? and conditions.first
				@enable_event_condition_checkbox.active = conditions.first.enable_event		# TODO: set inconsistent ?
				@event_combobox.set_active_object(conditions.first.event)
				@event_off_radiobutton.active = conditions.first.event_invert

				@enable_child_index_range_checkbox.active = conditions.first.enable_child_index		# TODO: set inconsistent ?
				@child_index_min_spinbutton.value = (conditions.first.child_index_min || 0) + 1
				@child_index_max_spinbutton.value = (conditions.first.child_index_max || 0) + 1
			end
		else
			@conditions_container.visible = false
		end

		present_modal
		@title_entry.grab_focus

		# deselect title so user doesn't overwrite it with a single keypress (unless it's the default/boring title eg. "Variable")
		@title_entry.position = -1 unless (@objects.size == 1 && @title_entry.text == @objects.first.default_title || @title_entry.text == @objects.first.class.title)

		# Prepare tag widgets
		if @tag_treeview
			@tag_treeview.update_all
			@tag_treeview.unselect_all
			@tag_entry.text = ''
		end

		@setting_values = false
	end

	def update_objects
		# ignore any calls if we're setting controls from ruby values (this can be done via GTK but this is easier)
		return if @setting_values

		@objects.each { |object|
			if object.respond_to?(:conditions)
				object.conditions.enable_event = @enable_event_condition_checkbox.active?
				object.conditions.event = @event_combobox.active_object
				object.conditions.event_invert = @event_off_radiobutton.active?

				object.conditions.enable_child_index = @enable_child_index_range_checkbox.active?
				object.conditions.child_index_min = @child_index_min_spinbutton.value.to_i - 1
				object.conditions.child_index_max = @child_index_max_spinbutton.value.to_i - 1
			end
		}
	end

	def on_title_entry_changed
		title = @title_entry.text

		# Don't overwrite existing, non-matching titles with empty string (happens immediately upon opening the dialog)
		return if title.empty? and @objects.size > 1

		@objects.each { |obj| obj.title = title }
		objects_changed_notify(@objects)
		update_window_title
	end


	def on_add_condition_event_button_clicked
		hide
		$gui.create_parent_user_object(:event) { |event|
			@objects.each { |obj| obj.conditions.event = event }
			objects_changed_notify
		}
	end
end
