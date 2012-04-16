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

# The GUI object holds shared objects for GUIs, such as GTK liststores

# Stuff required for the GUI (TODO: move liststores to control window?)
require 'actor_liststore', 'actor_tag_liststore', 'director_liststore', 'director_tag_liststore', 'project_effect_liststore', 'theme_liststore', 'theme_tag_liststore', 'curve_liststore', 'curve_liststore_increasing', 'slider_name_liststore', 'button_name_liststore', 'variable_liststore', 'event_liststore'

require 'editor_window', 'callbacks'

class GUI
	include Callbacks

	callback :reload

	pipe :run_performer!, :editor_window

	pipe :positive_message, :editor_window
	pipe :negative_message, :editor_window
	pipe :retire_message, :editor_window

	attr_reader :window_width, :window_height

	GTK_TO_LUZ_BUTTON_NAMES = {'Control_L' => 'Left Control', 'Control_R' => 'Right Control', 'Alt_L' => 'Left Alt', 'Alt_R' => 'Right Alt', 'Shift_L' => 'Left Shift', 'Shift_R' => 'Right Shift', 'bracketleft' => 'Left Bracket', 'bracketright' => 'Right Bracket', 'BackSpace' => 'Backspace'}

	def initialize
		Gtk.key_snooper_install { |grab_widget, event| on_global_keypress(grab_widget, event) }

		$engine.on_clear_objects {
			clear_objects
		}
		$engine.on_new_project {
			@actor_tag_model.set_objects(Actor.tags)
			@director_tag_model.set_objects(Director.tags)
			@theme_tag_model.set_objects(Theme.tags)
		}
		$engine.on_new_slider { |name|
			@slider_name_model.add(name)
		}
		$engine.on_new_button { |name|
			@button_name_model.add(name)
		}
		@snap_to_grid = false
	end

	def snap_to_grid?
		(@snap_to_grid ^ $settings['snap-to-grid'])
	end

	def on_global_keypress(grab_widget, event)
		if event.event_type == Gdk::Event::KEY_PRESS
			@snap_to_grid = true if (event.keyval == Gdk::Keyval::GDK_Shift_L || event.keyval == Gdk::Keyval::GDK_Shift_R)

			# Send key press to engine
			if $engine.on_button_down(gtk_keyval_to_luz_button_name(event.keyval), frame_offset=1)		# attribute to the NEXT frame, because the Gtk queue is emptied *between* frames
				# $engine.on_button_down returns true if button press was sent to a "grab".
				# In that case, we don't want the GUI to respond, so we return true ("handled") to GTK.
				return true
			end
		elsif event.event_type == Gdk::Event::KEY_RELEASE
			@snap_to_grid = false if (event.keyval == Gdk::Keyval::GDK_Shift_L || event.keyval == Gdk::Keyval::GDK_Shift_R)

			$engine.on_button_up(gtk_keyval_to_luz_button_name(event.keyval), frame_offset=1)
		end
		return false		# continue processing of this keypress
	end

	def gtk_keyval_to_luz_button_name(keyval)
		name = Gdk::Keyval.to_name(keyval) || ''		# GTK can give us a nil sometimes
		sprintf('Keyboard / %s', GTK_TO_LUZ_BUTTON_NAMES[name] || name.humanize)
	end

	def create_windows
		section('Creating Editor Window') {
			@editor_window = EditorWindow.new
			@editor_window.show
		}
		@window_width, @window_height = Gdk::Screen.default.width, Gdk::Screen.default.height
	end

	def long_process(text='Doing something important...')
		positive_message(text)
		Gtk.main_clear_queue
		yield
		retire_message
	end

	# yields the newly created object
	def create_parent_user_object(type, &proc)
		@editor_window.set_editor_page_from_type(type)
		Gtk.main_clear_queue ; sleep 0.2									# for usability, delay before adding a new item so user can see the before and after state
		@editor_window.yield_new_parent_object(&proc)
	end

	# $gui.window is used by GUI widgets program-wide eg. when creating pixbuf/pixmaps
	pipe :window, :editor_window

	# Shared object models
	attr_accessor :actor_model, :director_model, :project_effect_model, :curve_model, :curve_model_increasing, :theme_model, :slider_name_model, :button_name_model, :variable_model, :event_model

	# Tag models
	attr_accessor :actor_tag_model, :director_tag_model, :theme_tag_model

	def create_treeview_models
		# Project models (keep in handy array for easy clearing)
		@project_models = [
			@actor_model = ActorListStore.new,
			@actor_tag_model = ActorTagListStore.new,

			@director_model = DirectorListStore.new,
			@director_tag_model = DirectorTagListStore.new,

			@project_effect_model = ProjectEffectListStore.new,

			@curve_model = CurveListStore.new,
			@curve_model_increasing = CurveListStoreIncreasing.new(@curve_model),

			@theme_model = ThemeListStore.new,
			@theme_tag_model = ThemeTagListStore.new,

			@variable_model = VariableListStore.new,
			@event_model = EventListStore.new,
		]

		# GUI models
		@slider_name_model = SliderNameListStore.new
		@button_name_model = ButtonNameListStore.new
	end

	def clear_objects
		@project_models.each { |model| model.clear }
	end

	def choose_file(options = {})
		@editor_window.with_saved_set {
			project_directory = File.dirname(@editor_window.current_file_path)

			@@dialog ||= Gtk::FileChooserDialog.new("Open File",
																					window,
																					Gtk::FileChooser::ACTION_OPEN,
																					nil,
																					[Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
																					[Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])

			filter = Gtk::FileFilter.new
			filter.add_pattern(options[:filter_pattern]) if options[:filter_pattern]
			filter.add_mime_type(options[:filter_mime_type]) if options[:filter_mime_type]

			@@dialog.filter = filter		# otherwise nil

			@@dialog.current_folder = project_directory

			#
			# Present dialog
			#
			if @@dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
				#
				# User chose a file
				#
				filepath = @@dialog.filename
				filedir = File.dirname(filepath)
				filename = filepath.without_prefix(filedir).without_prefix('/')

				#
				# Did they choose a file outside the project folder?
				#
				if filedir.has_prefix?(project_directory)
					yield filepath.without_prefix(project_directory).without_prefix('/')

				else
					#
					# We'll need to copy it in...
					#
					dest_filepath = File.join(project_directory, filename)

					# ...unless we'd be overwriting another file
					if File.exists?(dest_filepath)
						# use it instead (TODO: warn user? rename?)
						yield dest_filepath
					else
						File.cp(filepath, dest_filepath)
						yield filename
					end
				end
			end
			@@dialog.hide
		}
	end

	def after_delete_confirmation(objects)
		return yield unless $settings['confirm-delete']

		case (count = objects.size)
		when 0
			return
		when 1
			yield if EasyDialog.new(self, :icon => :question, :header => "Delete \"#{objects.first.title}\"?", :body => "Objects cannot be undeleted.", :buttons => [[:cancel, '_Cancel', :cancel], [:delete, '_Delete', :delete]]).show_modal == :delete
		else
			object_titles = objects[0..4].collect { |o| "- #{o.title}" }.join("\n")
			object_titles += "- <i>and #{count - 5} more...</i>" if count > 5
			yield if EasyDialog.new(self, :icon => :question, :header => "Delete #{count} selected objects?", :body => "#{object_titles}\n\nObjects cannot be undeleted.", :buttons => [[:cancel, '_Cancel', :cancel], [:delete, '_Delete', :delete]]).show_modal == :delete
		end
	end

	def safe_open_file(path)
		if File.file? path and File.owned? path
			open("|gnome-open #{path}")
			positive_message "Opening #{File.basename(path)} ..."
		end
	end
	
	def safe_open_image(path)
		if File.file? path and File.owned? path
			open("|gimp #{path}")
			positive_message "Opening #{File.basename(path)} ..."
		end
	end
end
