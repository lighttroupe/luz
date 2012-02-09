 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
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

require 'user_object_editor_window', 'user_object_properties_editor_window', 'parent_user_object_treeview_menu', 'child_user_object_treeview_menu'
require 'glade_window'

class ParentUserObjectEditorWindow < UserObjectEditorWindow
	pipe :add_and_select_only, :parent_treeview

	# These are for notification about new classes (via plugins)  TODO: can they listen more directly?
	pipe :add_parent_class, :add_parent_window, :method => :add_class
	pipe :add_child_class, :add_child_window, :method => :add_class

	pipe :select_parent, :parent_treeview, :method => :select_only

	callback :parent_selected
	callback :child_list_changed

	attr_reader :selected_parents

	def initialize(glade_root, parent_class, parent_treeview_class, parent_editor_class, child_class, child_treeview_class, child_editor_class, tag_model=nil)
		super(glade_root)

		@parent_class, @child_class = parent_class, child_class

		@selected_parents = []
		@selected_children = []

		###################################################################
		# Parent Treeview
		###################################################################
		if @parent_class
			@parent_user_object_properties_editor_window = UserObjectPropertiesEditorWindow.new(tag_model)
			@parent_user_object_properties_editor_window.on_objects_changed { @parent_treeview.update_selected ; on_parent_list_changed }

			@parent_treeview = parent_treeview_class.new.show
			@parent_treeview_container.add(@parent_treeview)
			@parent_treeview.on_selection_change { on_parent_selection_change }
			@parent_treeview.on_focus { on_parent_selection_change }
			@parent_treeview.on_order_change { on_parent_list_changed }
			@parent_treeview.on_activated { @parent_treeview.cancel_row_grab ; edit_selected_parents }
			#@parent_treeview.on_double_click { |event| (@parent_treeview.unselect_all ; add_parent) if @parent_treeview.get_path_at_pos(event.x, event.y).nil? }		# clicking in empty area

			@parent_treeview_menu = ParentUserObjectTreeviewMenu.new
			@parent_treeview_menu.on_new { add_parent }
			@parent_treeview_menu.on_new_child { add_child }
			@parent_treeview_menu.hide_new_child_option unless @child_class
			@parent_treeview_menu.on_edit { edit_selected_parents }
			@parent_treeview_menu.on_clone { clone_selected_parents }
			@parent_treeview_menu.on_delete { delete_selected_from_parent_treeview }
			@parent_treeview.on_context_menu { |event| on_parent_selection_change ; @parent_treeview_menu.popup_for_objects(@selected_parents, event) }

			# Parent Editor
			@parent_editor = parent_editor_class.new.hide
			@editor_container_vbox.add(@parent_editor)

			# Changes to object should be reflected in treeview
			@parent_editor.on_change { @parent_treeview.update_selected } # Allow updating of preview
		end

		###################################################################
		# Child Treeview
		###################################################################
		if @child_class
			@child_user_object_properties_editor_window = UserObjectPropertiesEditorWindow.new
			@child_user_object_properties_editor_window.on_objects_changed { @child_treeview.update_selected ; on_child_list_changed }

			@child_treeview = child_treeview_class.new.show
			@child_treeview_container.add(@child_treeview)
			@child_treeview.on_selection_change { on_child_selection_change }
			@child_treeview.on_focus { on_child_selection_change }
			@child_treeview.on_order_change { on_child_list_changed }
			@child_treeview.on_activated { @child_treeview.cancel_row_grab ; edit_selected_children }
			#@child_treeview.on_double_click { |event| (@child_treeview.unselect_all ; add_child) if @child_treeview.get_path_at_pos(event.x, event.y).nil? }		# clicking in empty area

			@child_treeview_menu = ChildUserObjectTreeviewMenu.new
			@child_treeview_menu.on_new { add_child }
			@child_treeview_menu.on_edit { edit_selected_children }
			@child_treeview_menu.on_clone { clone_selected_children }
			@child_treeview_menu.on_delete { delete_selected_from_child_treeview }
			@child_treeview.on_context_menu { |event| on_child_selection_change ; @child_treeview_menu.popup_for_objects(@selected_children, event) }

			# Child Editor
			@child_editor = child_editor_class.new.hide
			@editor_container_vbox.add(@child_editor)

			# Changes to object should be reflected in treeview
			@child_editor.on_change { @child_treeview.update_selected }
		end
	end

	# Setting / Adding
	def set_parent_objects(objs)
		@parent_treeview.set_objects(objs)
		on_parent_list_changed
	end

	def add_parent
		add_parent_by_class(@parent_class)
	end

	def yield_new_parent_object
		yield add_parent_by_class(@parent_class)
	end

	# returns the new object
	def add_parent_by_class(klass)
		new_object = klass.new
		@parent_treeview.add_after_and_select_only(new_object, @selected_parents.last)
		on_parent_list_changed
		return new_object
	end

	def add_child
		add_child_by_class(@child_class)
	end

	# returns the new object or nil
	def add_child_by_class(klass)
		return nil if @selected_parents.empty?

		new_object = klass.new
		@child_treeview.add_after_and_select_only(new_object, @selected_children.last)
		on_child_list_changed
		return new_object
	end

	def edit_selected
		edit_selected_parents if @parent_treeview.has_focus?
		edit_selected_children if @child_treeview and @child_treeview.has_focus?
	end

	def selected_user_objects
		return @selected_parents if @parent_treeview.has_focus?
		return @selected_children if @child_treeview.has_focus?
	end

	def edit_selected_parents
		#	TODO:	edit-in-place for a single row selected?
		@parent_user_object_properties_editor_window.show_for(@selected_parents) unless @selected_parents.empty?
	end

	def edit_selected_children
		@child_user_object_properties_editor_window.show_for(@selected_children) unless @selected_children.empty?
	end

	def update_object(object)
		@parent_treeview.update_object(object) if object.is_a? @parent_class
		@child_treeview.update_object(object) if object.is_a? @child_class

		# TODO: is this correct?
#		if object.is_a? @parent_class
#			@parent_treeview.update_object(object)
#			on_parent_list_changed
#		end

#		if object.is_a? @child_class
#			@child_treeview.update_object(object)
#			on_child_list_changed
#		end
	end

	def update_all
		@parent_treeview.update_all
		@child_treeview.update_all
	end

	def selected_parents_each
		@selected_parents.each { |parent| yield parent }
	end

	def delete_selected
		delete_selected_from_parent_treeview if @parent_treeview and @parent_treeview.has_focus?
		delete_selected_from_child_treeview if @child_treeview and @child_treeview.has_focus?
	end

	def delete_selected_from_parent_treeview
		$gui.after_delete_confirmation(@selected_parents) {
			@selected_parents.each { |obj| obj.before_delete }
			@parent_treeview.delete_selected
			on_parent_list_changed
			$gui.positive_message("Deleted.")
		}
	end

	def delete_selected_from_child_treeview
		$gui.after_delete_confirmation(@selected_children) {
			@child_treeview.delete_selected
			on_child_list_changed
			$gui.positive_message("Deleted.")
		}
	end

	def clone_selected
		clone_selected_parents if @parent_treeview and @parent_treeview.has_focus?
		clone_selected_children if @child_treeview and @child_treeview.has_focus?
	end

	def clone_selected_parents
		new_objects = @selected_parents.collect { |parent_user_object| parent_user_object.deep_clone { |obj| !(obj.is_a? ParentUserObject) } }
		@parent_treeview.add_after_and_select_only(new_objects, @selected_parents.last)
		on_parent_list_changed
	end

	def clone_selected_children
		new_objects = @selected_children.collect { |child_user_object| child_user_object.deep_clone { |obj| !(obj.is_a? ParentUserObject) } }
		@child_treeview.add_after_and_select_only(new_objects, @selected_children.last)
		on_child_list_changed
	end

	def on_parent_selection_change
		@selected_parents = @parent_treeview.selected

		# Parent is selected and editor is active for parent, so deselect children (makes GUI more clear)
		@child_treeview.unselect_all if @child_treeview

		# Change settings display
		if @selected_parents.size == 1
			@child_treeview.build_for(@selected_parents.first) if @child_treeview
			on_parent_treeview_focus
			parent_selected_notify(@selected_parents.first)
			@new_child_button.sensitive = true
		else
			@child_treeview.clear if @child_treeview
			@parent_editor.clear
			@child_editor.clear if @child_editor
			@new_child_button.sensitive = false
		end

		if @selected_parents.empty?
			@edit_parent_button.sensitive = false
			@clone_parent_button.sensitive = false
			@delete_parent_button.sensitive = false
		else
			@edit_parent_button.sensitive = true
			@clone_parent_button.sensitive = true
			@delete_parent_button.sensitive = true
		end
	end

	def on_parent_treeview_focus
		# Parent is selected and editor is active for parent, so deselect children (makes GUI more clear)
		@child_treeview.unselect_all if @child_treeview

		@child_editor.hide if @child_editor
		@parent_editor.create_for(@selected_parents.first)
		@parent_editor.show_all
	end

	def on_child_selection_change
		@selected_children = @child_treeview.selected

		if @selected_children.empty?
			@parent_editor.clear
			@child_editor.clear
			@edit_child_button.sensitive = false
			@clone_child_button.sensitive = false
			@delete_child_button.sensitive = false
		else
			on_child_treeview_focus
			@edit_child_button.sensitive = true
			@clone_child_button.sensitive = true
			@delete_child_button.sensitive = true
		end
	end

	def on_child_treeview_focus
		@parent_editor.hide
 		@child_editor.create_for(@selected_children.first)
		@child_editor.show_all
	end

	def on_parent_list_changed
		$engine.project_changed!
	end

	def on_child_list_changed
		@selected_parents.first.effects = @child_treeview.objects if @selected_parents.size == 1
		$engine.project_changed!
	end

	def each_selected_parent
		@parent_treeview.selected.each { |parent| yield parent }
	end
end

