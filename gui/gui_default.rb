multi_require 'gui_pointer_behavior', 'gui_object', 'gui_value', 'gui_string', 'gui_numeric', 'gui_label', 'gui_box', 'gui_window', 'gui_hbox', 'gui_vbox', 'gui_list', 'gui_list_select', 'gui_scrollbar', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_time_control', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_director', 'gui_event', 'gui_variable', 'gui_font_select', 'gui_engine_button', 'gui_engine_button_renderer', 'gui_engine_slider', 'gui_engine_slider_renderer', 'gui_radio_buttons', 'gui_object_renderer', 'gui_main_menu', 'gui_settings_window', 'gui_actor_view', 'gui_director_view', 'gui_user_object_editor', 'gui_delete_button', 'gui_enter_exit_button', 'gui_enter_exit_popup', 'gui_add_window', 'gui_interface', 'gui_director_menu', 'gui_actors_flyout', 'gui_variables_flyout', 'gui_message_bus_monitor', 'gui_file_dialog', 'gui_directory_dialog', 'gui_image_dialog', 'gui_confirmation_dialog', 'keyboard', 'gui_user_object_renderer', 'gui_user_object_class_renderer', 'gui_child_user_object_renderer', 'gui_project_effect_renderer', 'gui_actor_renderer', 'gui_actor_effect_renderer', 'gui_director_renderer', 'gui_event_renderer', 'gui_event_input_renderer', 'gui_variable_renderer', 'gui_variable_input_renderer', 'gui_curve_renderer', 'gui_curve_increasing_renderer', 'gui_theme_renderer', 'gui_style_renderer', 'gui_list_popup', 'gui_output_view_button', 'gui_actor_class_flyout', 'gui_director_edit_button', 'gui_director_view_button', 'cartesian_scaffolding', 'camera', 'gui_object_renderer_button', 'gui_file_object', 'gui_class_instance_renderer_button', 'gui_actor_class_button'
load_directory(Dir.pwd + '/gui/addons/', '**.rb')		# Addons to existing objects

class GuiDefault < GuiInterface
	ACTOR_BACKGROUND_COLOR    = [0,0,0,0]
	DIRECTOR_BACKGROUND_COLOR = [0,0,0,0]
	ACTOR_VIEW_COLOR = [1,0.5,0.5,1]
	DIRECTOR_VIEW_COLOR = [0.5,1,0.5,1]
	OUTPUT_VIEW_COLOR = [0.5,0.5,1,1]
	VIEW_COLOR_FOR_MODE = {:actor => ACTOR_VIEW_COLOR, :director => DIRECTOR_VIEW_COLOR, :output => OUTPUT_VIEW_COLOR}

	DEFAULT_PROJECT_NAME = 'project.luz'

	GUI_ALPHA_SETTING_KEY = 'gui-alpha'

	INPUT_MANAGER_COMMAND = 'input-manager/input-manager'
	SPECTRUM_ANALYZER_COMMAND = 'spectrum-analyzer/spectrum-analyzer'
	OPEN_DIRECTORY_COMMAND = 'gnome-open'
	OPEN_RUBY_FILE_COMMAND = 'gnome-open'

	pipe [:positive_message, :negative_message], :message_bar

	attr_accessor :mode, :gui_alpha, :chosen_next_director
	attr_reader :gui_font, :user_object

	def initialize
		super
		preload_images
		create!
		@gui_alpha = 1.0
		@gui_font = "Ubuntu"		# "Comic Sans MS" "eufm10"
	end

	def preload_images
		File.read('gui/preload-images').split("\n").each { |path| $engine.load_image(path) }
	end

	def reload_notify
		clear!
		create!
		set_initial_state_from_project
	end

	def set_initial_state_from_project
		@user_object = nil					# this object the user is editing
		@user_object_editor = nil		# editor widget (window)

		# Auto-select first director
		director = $engine.project.directors.first
		self.chosen_director = director
		self.chosen_actor = nil
		self.mode = :output
	end

	#
	# Preferences
	#
	def close_user_object_editor_on_click?
		false		# TODO: per-pointer preference?
	end

	#
	# open/close
	#
	def toggle!
		switch_state({:open => :closed, :closed => :open}, duration=0.35)
	end

	#
	# Mode
	#
	def rendering_output?
		@mode == :output
	end
	def rendering_director?
		@mode == :director
	end
	def rendering_actor?
		@mode == :actor
	end

	def active_view
		if @mode == :actor
			@actor_view
		elsif @mode == :director
			@director_view
		end
	end

	# Actor and Director selection
	pipe [:chosen_actor], :actor_view, :method => :actor
	pipe [:chosen_actor=], :actor_view, :method => :actor=
	pipe [:chosen_director], :director_view, :method => :director

	def chosen_director=(director)
		@director_view.director = director
		@actors_flyout.actors = director.actors
		self.mode = :director
		clear_user_object_editor
		close_directors_menu!
	end

	#
	# UserObject factory
	#
	pipe :new_event!, :variables_flyout
	pipe :new_variable!, :variables_flyout

	def new_theme!(pointer=nil)
		$engine.project.themes << theme=Theme.new
		build_editor_for(theme, {:pointer => pointer})
		theme
	end

	#
	# File Utils
	#
	def choose_image
		return $gui.positive_message "Save Project before adding images" unless $engine.project.path
		@dialog_container << dialog = GuiImageDialog.new('Choose Image', ['png','gif','jpg','jpeg']).set(:scale_x => 0.8, :scale_y => 0.8, :offset_y => -0.1)
		dialog.on_selected { |path| dialog.remove_from_parent! ; yield $engine.project.media_file_path(path) }
		dialog.on_closed { dialog.remove_from_parent! }
		dialog.show_for_path(File.dirname($engine.project.path))
	end

	def choose_project_file
		dialog = GuiFileDialog.new('Choose Luz Project to Open', ['luz'], $settings['recent-projects'])
		dialog.on_closed { dialog.remove_from_parent! }
		dialog.on_selected { |path| dialog.remove_from_parent! ; yield path }
		dialog.show_for_path($engine.project.path ? File.dirname($engine.project.path) : default_directory)
		@dialog_container << dialog
	end

	def choose_project_path
		@dialog_container << dialog = GuiDirectoryDialog.new('Choose Directory for New project.luz')		# TODO: convert to a save-file-to-directory situation
		dialog.on_closed { dialog.remove_from_parent! }
		dialog.on_selected { |path|
			dialog.remove_from_parent!
			choose_file_name { |file_name|
				path_with_file_name = File.join(path, file_name)
				if File.exists?(path_with_file_name)
					negative_message 'File Already Exists'
					negative_message 'Refusing to Overwrite'
				else
					yield path_with_file_name
				end
			}
		}
		dialog.show_for_path($engine.project.path ? File.dirname($engine.project.path) : default_directory)
	end

	def choose_file_name
		yield DEFAULT_PROJECT_NAME		# TODO
	end

	def default_directory
		Dir.home
	end

	def new_project
		save_changes_before {
			choose_project_path { |path|
				# TODO: assert doesn't exist
				FileUtils.cp BASE_SET_PATH, path		# copy into place
				$application.open_project(path)
				$settings['recent-projects'].unshift(path)
			}
		}
	end

	def save_project
		if $engine.project.path
			if $engine.project.save
				positive_message 'Project Saved'
				yield if block_given?
			else
				negative_message 'Save Failed'
			end
		else
			choose_project_path { |path|
				if $engine.project.save_to_path(path)
					positive_message 'Project Saved'
					yield if block_given?
				else
					negative_message 'Save Failed'
				end
			}
		end
	end

	def open_project
		save_changes_before {
			choose_project_file { |path|
				if $application.open_project(path)
					$settings['recent-projects'].delete(path)
					$settings['recent-projects'].unshift(path)
				else
					negative_message 'Open Failed'
				end
			}
		}
	end

	def open_most_recent_project
		save_changes_before {
			path = $settings['recent-projects'].first
			if $application.open_project(path)
				# :D
			else
				negative_message 'Open Failed'
			end
		}
	end

	def save_changes_before
		return yield unless $engine.project.changed?
		body = $engine.project.change_count.plural("unsaved change", "unsaved changes")
		confirmation = GuiConfirmationDialog.new("Save Project before continuing?", body, "Continue without saving", "Save Project")
		self << confirmation
		confirmation.on_yes    { confirmation.remove_from_parent! ; yield }
		confirmation.on_no     { confirmation.remove_from_parent! ; save_project { yield } }
		confirmation.on_cancel { confirmation.remove_from_parent! }
	end

	#
	# Creating GUI -- minimal start for a new object: self << GuiObject.new.set(:scale_x => 0.1, :scale_y => 0.1, :offset_x => 0.0, :offset_y => 0.0)
	#
	def create!
		@actor_view = GuiActorView.new
		@director_view = GuiDirectorView.new

		#
		# Actors / Directors flyout
		#
		self << @actors_flyout = GuiActorsFlyout.new.set(:scale_x => 0.12, :scale_y => 1.0, :offset_x => 0.5 - 0.06).
			add_state(:open, {:offset_x => 0.44, :hidden => false}).
			set_state(:closed, {:offset_x => 0.56, :hidden => true})

		# Actors corner button (bottom right)
		self << (@actors_button = GuiButton.new.set(:scale_x => -0.04, :scale_y => -0.06, :offset_x => 0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png'), :background_image_hover => $engine.load_image('images/corner-hover.png'), :background_image_click => $engine.load_image('images/corner-click.png')))
		@actors_button.on_clicked {
			toggle_actors_flyout!
		}

		# Directors corner button (top right)
		self << (@directors_button = GuiButton.new.set(:scale_x => -0.04, :scale_y => 0.06, :offset_x => 0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png'), :background_image_hover => $engine.load_image('images/corner-hover.png'), :background_image_click => $engine.load_image('images/corner-click.png')))
		@directors_button.on_clicked {
			open_directors_menu!
		}

		#
		# Events / Variables flyout
		#
		self << @variables_flyout = GuiVariablesFlyout.new.set(:scale_x => 0.12, :scale_y => 1.0, :offset_x => -0.44).
			add_state(:open, {:hidden => false, :offset_x => -0.44}).
			set_state(:closed, {:hidden => true, :offset_x => -0.56})

		# Events/Variables corner button (bottom left)
		self << @events_button = GuiButton.new.set(:scale_x => 0.04, :scale_y => -0.06, :background_image => $engine.load_image('images/corner.png'), :background_image_hover => $engine.load_image('images/corner-hover.png'), :background_image_click => $engine.load_image('images/corner-click.png')).
			add_state(:closed, {:hidden => true, :offset_x => -0.55, :offset_y => -0.53}).
			set_state(:open, {:hidden => false, :offset_x => -0.48, :offset_y => -0.47})
		@events_button.on_clicked {
			toggle_inputs_flyout!
		}

		# Project corner button (upper left)
		self << @project_menu_button = GuiButton.new.set(:scale_x => 0.04, :scale_y => 0.06, :offset_x => -0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png'), :background_image_hover => $engine.load_image('images/corner-hover.png'), :background_image_click => $engine.load_image('images/corner-click.png'))
		@project_menu_button.on_clicked {
			@overlay.switch_state({:closed => :open}, duration=0.4)
			@main_menu.switch_state({:closed => :open}, duration=0.2)
		}

		#
		# User Object Editor
		#
		self << @user_object_editor_container = GuiBox.new

		# Reopen button shows after you close the user object editor
		self << (@reopen_button=GuiButton.new.set(:scale_x => 0.1, :scale_y => 0.022, :offset_x => 0.0, :background_image => $engine.load_image('images/buttons/reopen-user-object-editor.png'), :background_image_hover => $engine.load_image('images/buttons/reopen-user-object-editor-hover.png'))).
			add_state(:open, {:offset_y => -0.5 + 0.011, :hidden => false}).
			set_state(:closed, {:offset_y => -0.5 - 0.011, :hidden => true})
		@reopen_button.on_clicked { reshow_latest! }

		# Beat Monitor
		self << @beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:scale_x => 0.10, :scale_y => 0.02, :background_scale_x => 1.2, :background_scale_y => 1.2, :background_image => $engine.load_image('images/drawer-n.png')).
			add_state(:closed, {:offset_x => 0.0, :offset_y => 0.55, :hidden => true}).
			set_state(:open, {:offset_x => 0.0, :offset_y => 0.49, :hidden => false})

		#
		# OVERLAY LEVEL (objects created below this line aren't obscured by overlay)
		#
		self << @overlay = GuiWindow.new.set(:background_image => $engine.load_image('images/overlay.png')).
			add_state(:open, {:opacity => 1.0, :hidden => false}).
			set_state(:closed, {:opacity => 0.0, :hidden => true})

		# Main menu
		self << @main_menu = GuiMainMenu.new.set(:opacity => 0.0, :hidden => true).
			add_state(:open, {:scale_x => 1.0, :opacity => 1.0, :hidden => false}).
			set_state(:closed, {:scale_x => 2.0, :opacity => 0.0, :hidden => true})
		@main_menu.on_new { new_project }
		@main_menu.on_open { open_project }
		@main_menu.on_save { save_project }
		#@main_menu.on_save_as { save_project_as... }
		@main_menu.on_close { close_main_menu! }
		@main_menu.on_quit { save_changes_before { $application.finished! } }

		# Director Menu
		self << @directors_menu = GuiDirectorMenu.new($engine.project.directors).
			add_state(:open, {:scale_x => 1.0, :scale_y => 1.0, :opacity => 1.0, :hidden => false}).
			set_state(:closed, {:scale_x => 1.1, :scale_y => 1.1, :opacity => 0.0,:hidden => true})

		# Message Bar
		self << (@message_bar = GuiMessageBar.new.set(:opacity => 0.0, :offset_x => 0.0, :offset_y => 0.5 - 0.05, :scale_x => 0.32, :scale_y => 0.05))

		# Time Control
		self << @time_control = GuiTimeControl.new.set(:scale_x => 0.02, :scale_y => 0.01, :background_scale_x => 1.2, :background_scale_y => 1.2, :background_image => $engine.load_image('images/drawer-n.png')).
			add_state(:open, {:offset_x => 0.0, :offset_y => 0.495, :hidden => false}).
			set_state(:closed, {:offset_x => 0.0, :offset_y => 0.55, :hidden => true})

		self << @directors_list = GuiList.new([]).set(:hidden => true)

		self << @dialog_container = GuiBox.new

		self << text_layout_debugger if false

		add_state(:closed, {:scale_x => 1.5, :scale_y => 1.5, :opacity => 0.0, :hidden => true})
		set_state(:open, {:scale_x => 1.0, :scale_y => 1.0, :opacity => 1.0, :hidden => false})
	end

	#
	# build_editor_for is the main "object activated" message
	#
	def build_editor_for(user_object, options={})
		return unless user_object

		# extract options
		grab_keyboard_focus = options.delete(:grab_keyboard_focus)
		pointer = options[:pointer]
		editor = @user_object_editor if @user_object == user_object		# reuse editor if already showing this object
		editor_visible = (editor && !editor.hidden?)

		hide_reopen_button!

		case user_object				# "let's take a look at this ..."
		when Actor
			if editor_visible
				@actor_view.actor = user_object
				return
			else
				 #Rule: cannot edit one actor while viewing a different one (so show this actor while editing)
				@actor_view.actor = user_object if self.mode == :actor
			end
		end

		if user_object.is_a?(ParentUserObject) || user_object.is_a?(Project)		# TODO: responds_to? :effects ?
			# show editor for user_object
			clear_user_object_editor		# only support one for now

			@user_object_editor = create_user_object_editor_for_pointer(user_object, pointer || Vector3.new(0.0,-0.5), options)
			@user_object_editor.grab_keyboard_focus! if grab_keyboard_focus

			# becomes the current user_object
			@user_object = user_object
			@user_object_editor_container << @user_object_editor

			@user_object_editor
		else
			# tell editor its child was clicked (this is needed due to non-propagation of click messages: the user object gets notified, it tells us)
			parent = @user_object if @user_object && @user_object.effects.include?(user_object)		# TODO: hacking around children not knowing their parents for easier puppetry
			@user_object_editor.gui_fill_settings_list(user_object) if parent
			nil
		end
	end

	def edit_chosen_director_offscreen_render_actor!(klass)
		chosen_director.offscreen_render_actor_setting.set_to_new_actor_of_class(klass) unless chosen_director.offscreen_render_actor.present?
		chosen_director.offscreen_render_actor.one { |actor| build_editor_for(actor) }
	end

	#
	# Rendering
	#
	def view_color
		VIEW_COLOR_FOR_MODE[@mode]
	end

	def render
		# the visuals
		case @mode
		when :actor
			clear_screen(ACTOR_BACKGROUND_COLOR)
			$engine.with_content_aspect_ratio {
				@actor_view.gui_render
			}
		when :director
			clear_screen(DIRECTOR_BACKGROUND_COLOR)
			$engine.with_content_aspect_ratio {
				@director_view.gui_render
			}
		when :output
			yield
		when :none
			# ...
		end

		unless hidden?
			# the GUI on top
			with_alpha($settings[GUI_ALPHA_SETTING_KEY]) {
				gui_render		# renders children, ie the interface
				render_pointers
			}
		end
	end

	#
	# Deleting
	#
	def trash!(user_object)
		case user_object
		when Actor
			if user_object == self.chosen_director.offscreen_render_actor.actor
				self.chosen_director.offscreen_render_actor.actor = nil
			else
				@actors_flyout.remove(user_object)
				@actor_view.actor = nil if @actor_view.actor == user_object
			end
		when Director
			$gui.negative_message "Can't delete last director." and return if $engine.project.directors.count <= 1
			$engine.project.directors.delete(user_object)
			@directors_list.remove(user_object)
			if @director_view.director == user_object
				self.chosen_director = $engine.project.directors.first
			end
		when Variable, Event
			@variables_flyout.remove(user_object)
		end
		clear_user_object_editor if user_object == @user_object
	end

	#
	# Keyboard Interaction
	#
	def keyboard
		@keyboard ||= Keyboard.new(self)
	end
	def raw_key_down(value)
		keyboard.raw_key_down(value)
	end
	def raw_key_up(value)
		keyboard.raw_key_up(value)
	end
	def grab_keyboard_focus(object=nil, &proc)
		keyboard.grab(object, &proc)
	end
	def has_keyboard_focus?(object)
		keyboard.grabbed_by_object?(object)
	end
	def cancel_keyboard_focus!
		keyboard.cancel_grab!
	end
	def cancel_keyboard_focus_for(object)
		cancel_keyboard_focus! if has_keyboard_focus?(object)
	end
	def on_key_press(key)
		if key.control?
			case key
			when 'f8'
				launch_project_directory_browser
			when 'f9'
				launch_input_manager
			when 'f10'
				launch_spectrum_analyzer
			when 'f11'
				#$application.toggle_fullscreen!
			when 'left'
				if @variables_flyout.keyboard_focus?
					@variables_flyout.close!
					default_focus!
				elsif @variables_flyout.open?
					@variables_flyout.grab_keyboard_focus!
				else
					@variables_flyout.open!
					@variables_flyout.grab_keyboard_focus!
				end
			when 'right'
				if @actors_flyout.keyboard_focus?
					@actors_flyout.close!
					default_focus!
				elsif @actors_flyout.open?
					@actors_flyout.grab_keyboard_focus!
				else
					@actors_flyout.open!
					@actors_flyout.grab_keyboard_focus!
				end
			when 'up'
				@directors_menu.open!
				@directors_menu.grab_keyboard_focus!
			when 'down'
				unless hide_something!
					reshow_latest!
				end
			#when 'return'
				#$application.toggle_fullscreen!
			when 'b'
				toggle_beat_monitor!
			when 't'
				toggle_time_control!
			when ','
				$engine.beat_half_time!
			when '.'
				$engine.beat_double_time!
			when 'r'
				$application.reload_code!
			when 's'
				save_project
			when 'f1'
				self.mode = :actor
			when 'f2'
				self.mode = :director
			when 'f3'
				self.mode = :output
			when 'f4'
				self.mode = :none
			when 'o'
				if key.shift?
					open_most_recent_project
				else
					open_project
				end
			when 'g'
				toggle_gc_timing
			when 'x'
				output_object_counts
				#ObjectSpace.each_object(Variable) { |variable| puts variable.title }
			end
		elsif key.alt?
			case key
			when 'down'
				select_next_actor!
				default_focus!
			when 'up'
				select_previous_actor!
				default_focus!
			end
		else
			# no modifier
			case key
			when 'escape'
				if @main_menu.visible?
					close_main_menu!
				elsif @directors_menu.visible?
					close_directors_menu!
				else
					toggle!
				end
			end
		end
	end

	def default_focus!
		user_object_editor = @user_object_editor

		if user_object_editor && user_object_editor.visible?
			user_object_editor.grab_keyboard_focus!
		elsif @actors_flyout.open?
			@actors_flyout.grab_keyboard_focus!
		elsif @variables_flyout.open?
			@variables_flyout.grab_keyboard_focus!
		else
			@keyboard.cancel_grab_silently!
		end
	end

	#
	# Mouse Interaction
	#
	def pointer_click_on_nothing(pointer)
		hide_something!
	end
	def pointer_double_click_on_nothing(pointer)
	end
	def scroll_up!(pointer)
		view = active_view
		view.scroll_up!(pointer) if view
	end
	def scroll_down!(pointer)
		view = active_view
		view.scroll_down!(pointer) if view
	end
	def scroll_left!(pointer)
		view = active_view
		view.scroll_left!(pointer) if view
	end
	def scroll_right!(pointer)
		view = active_view
		view.scroll_right!(pointer) if view
	end

	#
	# Utility methods
	#
	def create_user_object_editor_for_pointer(user_object, pointer, options)
		GuiUserObjectEditor.new(user_object, {:scale_x => 0.3, :scale_y => 0.05}.merge(options)).
			set({:offset_x => 0.0, :offset_y => -0.5, :opacity => 0.0, :scale_x => 0.65, :scale_y => 0.5, :hidden => false}).
			animate({:offset_x => 0.0, :offset_y => -0.3, :scale_x => 0.65, :scale_y => 0.4, :opacity => 1.0}, duration=0.2)
	end

	def clear_user_object_editor		# TODO: for pointer ?
		if @user_object_editor
			editor = @user_object_editor		# local cache (closures!)
			@user_object_editor.animate({:offset_y => -1.0}, duration=0.3) {
				editor.remove_from_parent!
				show_reopen_button! unless @user_object_editor
			}
			default_focus!
		end
		@last_user_object = @user_object
		@user_object = nil
		@user_object_editor = nil
	end

	def user_object_editor_edit_text
		@user_object_editor.edit_title if @user_object_editor
	end

	def hide_something!
		if @directors_menu.visible?
			close_directors_menu!
			default_focus!
			true
		elsif @variables_flyout.visible? or @actors_flyout.visible?
			close_inputs_flyout!
			close_actors_flyout!
			default_focus!
			true
		elsif (@user_object_editor && @user_object_editor.visible?) && close_user_object_editor_on_click?
			clear_user_object_editor
			default_focus!
			true
		else
			false
		end
	end

	def close_main_menu!
		@main_menu.switch_state({:open => :closed}, duration=0.1)
		@overlay.switch_state({:open => :closed}, duration=0.2)
	end

	# actor flyout
	def close_actors_flyout!
		@actors_flyout.switch_state({:open => :closed}, duration=0.2)
	end
	def toggle_actors_flyout!
		@actors_flyout.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	# event/variable flyout
	def close_inputs_flyout!
		@variables_flyout.switch_state({:open => :closed}, duration=0.2)
	end
	def toggle_inputs_flyout!
		@variables_flyout.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	# beat/time control
	def toggle_beat_monitor!
		@beat_monitor.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end
	def toggle_time_control!
		@time_control.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	# director menu
	def open_directors_menu!
		@directors_menu.switch_state({:closed => :open},durection=0.2)
		@directors_menu.grab_keyboard_focus!
	end
	def close_directors_menu!
		@directors_menu.switch_state({:open => :closed}, duration=0.1)
	end
	def toggle_directors_menu!
		@directors_menu.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	# reopen button (bottom center)
	def show_reopen_button!
		@reopen_button.switch_state({:closed => :open}, duration=0.2)
	end
	def hide_reopen_button!
		@reopen_button.switch_state({:open => :closed}, duration=0.1)
	end

	def reshow_latest!
		build_editor_for(@last_user_object, :grab_keyboard_focus => true) if @last_user_object
	end

	#
	# Next/Previous actor selection
	#
	def select_next_actor!
		return unless chosen_director && chosen_director.actors.size > 0
		index = chosen_director.actors.index(@user_object) || -1
		index = (index + 1) % chosen_director.actors.size
		actor = chosen_director.actors[index]
		build_editor_for(actor) unless @user_object == actor
	end

	def select_previous_actor!
		return unless chosen_director && chosen_director.actors.size > 0
		index = chosen_director.actors.index(@user_object) || -1
		index = (index - 1) % chosen_director.actors.size
		actor = chosen_director.actors[index]
		build_editor_for(actor) unless @user_object == actor
	end

	#
	# External Apps
	#
	def launch_input_manager
		if $engine.command_line(INPUT_MANAGER_COMMAND)
			positive_message "Launching Input Manager"
		else
			negative_message "Launching Input Manager Failed"
		end
	end

	def launch_spectrum_analyzer
		if $engine.command_line(SPECTRUM_ANALYZER_COMMAND)
			positive_message "Launching Spectrum Analyzer"
		else
			negative_message "Launching Spectrum Analyzer Failed"
		end
	end

	def launch_project_directory_browser
		negative_message('Save Project First') and return unless $engine.project.path
		directory = File.dirname($engine.project.path)
		$engine.command_line(OPEN_DIRECTORY_COMMAND, directory)
	end

	#
	# Debug
	#
	def toggle_gc_timing
		if GC::Profiler.enabled?
			puts GC::Profiler.result
			GC::Profiler.disable
			positive_message 'GC Results Printed'
		else
			GC::Profiler.enable
			positive_message 'GC Monitoring Enabled'
		end
	end

	def output_object_counts
		p (counts = ObjectSpace.count_objects)
		positive_message "#{counts[:TOTAL]} Objects, #{counts[:FREE]} Free"
	end

	def text_layout_debugger
		box = GuiBox.new.set(:scale_x => 0.5, :scale_y => 0.5)

		box << GuiLabel.new.set(:offset_x => -0.25, :scale_x => 0.5, :offset_y => 0.5-0.125, :scale_y => 0.25, :string => 'left', :width => 10, :text_align => :left)
		box << GuiLabel.new.set(:offset_x => -0.25, :scale_x => 0.5, :offset_y => 0.125, :scale_y => 0.25, :string => 'center', :width => 10, :text_align => :center)
		box << GuiLabel.new.set(:offset_x => -0.25, :scale_x => 0.5, :offset_y => -0.125, :scale_y => 0.25, :string => 'right', :width => 10, :text_align => :right)

		box << GuiLabel.new.set(:offset_x => 0.25, :scale_x => 0.5, :offset_y => 0.5-0.125, :scale_y => 0.25, :string => 'width:fill', :width => 6, :text_align => :fill)
		box << GuiLabel.new.set(:offset_x => 0.25, :scale_x => 0.5, :offset_y => 0.125, :scale_y => 0.25, :string => 'slightly longer text', :width => 6, :text_align => :fill)
		box << GuiLabel.new.set(:offset_x => 0.25, :scale_x => 0.5, :offset_y => -0.125, :scale_y => 0.25, :string => 'long text will squish to fit', :width => 6, :text_align => :fill)

		box << GuiLabel.new.set(:offset_x => -0.25, :scale_x => 0.5, :offset_y => -0.30, :scale_y => 0.1, :string => 'LLLLL', :width => 10, :text_align => :left)
		box << GuiLabel.new.set(:offset_x => -0.25, :scale_x => 0.3, :offset_y => -0.40, :scale_y => 0.1, :string => 'CCCCC', :width => 10, :text_align => :center)
		box << GuiLabel.new.set(:offset_x => -0.25, :scale_x => 0.1, :offset_y => -0.50, :scale_y => 0.04, :string => 'RRRRR', :width => 10, :text_align => :right)

		box << GuiLabel.new.set(:lines => 5, :width => 20, :text_align => :left, :offset_x => 0.25, :scale_x => 0.5, :offset_y => -0.35, :scale_y => 0.2, :string => '20x5 Here we have a left-aligned block of text supporting up to five lines of text.  It wraps on word boundaries.  This space intentionally not left blank.')
		box << GuiLabel.new.set(:lines => 3, :width => 15, :text_align => :center, :offset_x => 0.25, :scale_x => 0.5, :offset_y => -0.55, :scale_y => 0.2, :string => 'Same size box, but now center-aligned and supporting only three lines.')
		box << GuiLabel.new.set(:lines => 4, :width => 30, :color => [1,1,0], :text_align => :right, :font => 'FreeMono Bold Italic', :offset_x => 0.25, :scale_x => 0.5, :offset_y => -0.75, :scale_y => 0.2, :string => 'Labels have :color and :font settings, and support bold and italic text.  Labels are quite versatile!')

		box
	end
end
