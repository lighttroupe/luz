multi_require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_hbox', 'gui_vbox', 'gui_list', 'gui_scrollbar', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_time_control', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider', 'gui_radio_buttons', 'gui_object_renderer', 'gui_text_renderer', 'gui/fonts/bitmap-font', 'gui_main_menu', 'gui_window'
load_directory(Dir.pwd + '/gui/addons/', '**.rb')		# Addons to existing objects
multi_require 'gui_actor_view', 'gui_director_view', 'gui_preferences_box', 'gui_user_object_editor', 'gui_delete_button', 'gui_enter_exit_button', 'gui_enter_exit_popup', 'gui_add_window', 'gui_interface', 'gui_actor_class_button', 'gui_director_menu', 'gui_actors_flyout', 'gui_variables_flyout', 'gui_message_bus_monitor', 'gui_file_dialog', 'keyboard'

class GuiDefault < GuiInterface
	ACTOR_BACKGROUND_COLOR    = [0,0,0,0]
	DIRECTOR_BACKGROUND_COLOR = [0,0,0,0]

	ACTOR_VIEW_COLOR = [1,0.5,0.5,1]
	DIRECTOR_VIEW_COLOR = [0.5,1,0.5,1]
	OUTPUT_VIEW_COLOR = [0.5,0.5,1,1]

	pipe [:positive_message, :negative_message], :message_bar

	attr_accessor :mode, :directors_menu

	pipe :new_event!, :variables_flyout
	pipe :new_variable!, :variables_flyout

	def initialize
		super
		create!
		positive_message('Welcome to Luz 2.0')
	end

	def toggle!
		switch_state({:open => :closed, :closed => :open}, duration=0.35)
	end

	def reload_notify
		clear!
		create!
	end

	#
	# File Utils
	#
	def choose_image
		dialog = GuiFileDialog.new('Choose Image').set(:scale_x => 0.8, :scale_y => 0.8, :offset_y => -0.1)
		@dialog_container << dialog
		dialog.on_selected { |path|
			dialog.remove_from_parent!
			yield path
		}
		dialog.on_closed { dialog.remove_from_parent! }
		dialog.show_for_path(File.dirname($engine.project.path), ['png','gif','jpg','jpeg'])
	end

	def choose_project_file
		dialog = GuiFileDialog.new('Open Project').set(:scale_x => 0.8, :scale_y => 0.8, :offset_y => -0.1)
		@dialog_container << dialog
		dialog.on_selected { |path|
			dialog.remove_from_parent!
			yield path
		}
		dialog.on_closed { dialog.remove_from_parent! }
		dialog.show_for_path(File.dirname($engine.project.path), ['luz'])
	end

	#
	# Building the GUI
	#
	# Minimal start for a new object:
	#
	#  self << GuiObject.new.set(:scale_x => 0.1, :scale_y => 0.1, :offset_x => 0.0, :offset_y => 0.0)
	#
	def create!
		# Remember: this is drawn first-to-last

		@actor_view = GuiActorView.new	#.set(:opacity => 0.0, :hidden => true)
		@director_view = GuiDirectorView.new	#.set(:opacity => 0.0, :hidden => true)

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

		self << (@reopen_button=GuiButton.new.set(:scale_x => 0.1, :scale_y => 0.022, :offset_x => 0.0, :background_image => $engine.load_image('images/buttons/reopen-user-object-editor.png'))).
			add_state(:open, {:offset_y => -0.5 + 0.011, :hidden => false}).
			set_state(:closed, {:offset_y => -0.5 - 0.011, :hidden => true})
		@reopen_button.on_clicked { reshow_latest! }

		#
		# OVERLAY LEVEL (objects created below this line aren't obscured by overlay)
		#
		self << @overlay = GuiObject.new.set(:background_image => $engine.load_image('images/overlay.png')).
			add_state(:open, {:opacity => 1.0, :hidden => false}).
			set_state(:closed, {:opacity => 0.0, :hidden => true})

		# Main menu
		self << @main_menu = GuiMainMenu.new.set(:opacity => 0.0, :hidden => true).
			add_state(:open, {:scale_x => 1.0, :opacity => 1.0, :hidden => false}).
			set_state(:closed, {:scale_x => 2.0, :opacity => 0.0, :hidden => true})
		@main_menu.on_close {
			close_main_menu!
		}
		@main_menu.on_save {
			$engine.save
			positive_message 'Project Saved'
		}
		@main_menu.on_open {
			choose_project_file { |path|
				if $application.open_project(path)
					$gui.positive_message 'Opened successfully.'
				else
					$gui.negative_message 'Open failed.'
				end
			}
		}
		@main_menu.on_new {
			#save_changes_before {
				#choose_project_path { |path|
					# TODO: copy base.luz to that directory
					# TODO: open it
				#}
			#}
			$application.open_project(BASE_SET_PATH)
		}

		# Director Grid popup
		self << @directors_menu = GuiDirectorMenu.new($engine.project.directors).
			add_state(:open, {:scale_x => 1.0, :scale_y => 1.0, :opacity => 1.0, :hidden => false}).
			set_state(:closed, {:scale_x => 1.1, :scale_y => 1.1, :offset_y => 0.0,:hidden => true})

		# Message Bar
		self << (@message_bar = GuiMessageBar.new.set(:offset_x => 0.02, :offset_y => 0.5 - 0.05, :scale_x => 0.32, :scale_y => 0.05))

		# Beat Monitor
		self << @beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:scale_x => 0.10, :scale_y => 0.02, :background_scale_x => 1.2, :background_scale_y => 1.2, :background_image => $engine.load_image('images/drawer-n.png')).
			add_state(:closed, {:offset_x => 0.0, :offset_y => 0.55, :hidden => true}).
			set_state(:open, {:offset_x => 0.0, :offset_y => 0.49, :hidden => false})

		# Time Control
		self << @time_control = GuiTimeControl.new.set(:scale_x => 0.02, :scale_y => 0.01, :background_scale_x => 1.2, :background_scale_y => 1.2, :background_image => $engine.load_image('images/drawer-n.png')).
			add_state(:open, {:offset_x => 0.0, :offset_y => 0.495, :hidden => false}).
			set_state(:closed, {:offset_x => 0.0, :offset_y => 0.55, :hidden => true})

		self << @directors_list = GuiList.new([]).set(:hidden => true)

		self << @dialog_container = GuiBox.new

		add_state(:closed, {:scale_x => 1.5, :scale_y => 1.5, :opacity => 0.0, :hidden => true})
		set_state(:open, {:scale_x => 1.0, :scale_y => 1.0, :opacity => 1.0, :hidden => false})

		set_initial_state
	end

	def set_initial_state
		@user_object = nil					# this object the user is editing
		@user_object_editor = nil		# editor widget (window)

		# Auto-select first director
		director = $engine.project.directors.first

		# Hack to load project file format 1
		director.actors = $engine.project.actors if director.actors.empty? && !$engine.project.actors.empty?

		self.chosen_actor = nil
		self.chosen_director = director
		self.mode = :output
	end

	#
	# Actor and Director selection
	#
	pipe [:chosen_actor], :actor_view, :method => :actor
	pipe [:chosen_actor=], :actor_view, :method => :actor=
	pipe [:chosen_director], :director_view, :method => :director

	def chosen_director=(director)
		@director_view.director = director
		@actors_flyout.actors = director.actors
		self.mode = :director
		clear_user_object_editor
	end

	#
	# Rendering: render is called every frame, gui_render! only when the Editor plugin thinks it's visible 
	#
	def view_color
		case @mode
		when :actor
			ACTOR_VIEW_COLOR
		when :director
			DIRECTOR_VIEW_COLOR
		else
			OUTPUT_VIEW_COLOR
		end
	end

	def render
		case @mode
		when :actor
			clear_screen(ACTOR_BACKGROUND_COLOR)
			$engine.with_content_aspect_ratio {
				@actor_view.gui_render!
			}
		when :director
			clear_screen(DIRECTOR_BACKGROUND_COLOR)
			$engine.with_content_aspect_ratio {
				@director_view.gui_render!
			}
		when :output
			yield
		end
		gui_render!
	end

	#
	# build_editor_for is the main "object activated" message
	#
	def build_editor_for(user_object, options={})
		return unless user_object

		grab_keyboard_focus = options.delete(:grab_keyboard_focus)
		pointer = options[:pointer]
		editor = @user_object_editor if @user_object == user_object
		editor_visible = (editor && !editor.hidden?)

		hide_reopen_button!

		case user_object
		when Director
			close_directors_menu! #if self.chosen_director == user_object
			if self.chosen_director == user_object
				self.mode = :director
			else
				self.chosen_director = user_object
				clear_user_object_editor
				return
			end
		when Actor
			if editor_visible
				@actor_view.actor = user_object
				#self.mode = :actor
				return
			else
				# Rule: cannot edit one actor while viewing a different one (so show this actor while editing)
				@actor_view.actor = user_object if self.mode == :actor
			end
		when Variable, Event
			clear_user_object_editor and return if editor_visible
		end

		if user_object.is_a?(ParentUserObject) || user_object.is_a?(Project)		# TODO: responds_to? :effects ?
			# show editor for user_object
			clear_user_object_editor		# only support one for now

			@user_object_editor = create_user_object_editor_for_pointer(user_object, pointer || Vector3.new(0.0,-0.5), options)
			@user_object_editor.grab_keyboard_focus! if grab_keyboard_focus
			@user_object = user_object
			@user_object_editor_container << @user_object_editor

			@user_object_editor
		else
			# tell editor its child was clicked (this is needed due to non-propagation of click messages: the user object gets notified, it tells us)
			parent = @user_object if @user_object && @user_object.effects.include?(user_object)		# TODO: hacking around children not knowing their parents for easier puppetry
			parent.on_child_user_object_selected(user_object) if parent		# NOTE: can't click a child if parent is not visible, but the 'if' doesn't hurt

			nil
		end
	end

	def trash!(user_object)
		@actors_flyout.remove(user_object)
		@actor_view.actor = nil if @actor_view.actor == user_object

		@directors_list.remove(user_object)
		@director_view.director = nil if @director_view.director == user_object

		@variables_flyout.remove(user_object)

		clear_user_object_editor if user_object == @user_object
	end

	#
	# Utility methods
	#
	def create_user_object_editor_for_pointer(user_object, pointer, options)
		GuiUserObjectEditor.new(user_object, {:scale_x => 0.3, :scale_y => 0.05}.merge(options)).
			set({:offset_x => 0.0, :offset_y => -0.5, :opacity => 0.0, :scale_x => 0.65, :scale_y => 0.5, :hidden => false}).
			animate({:offset_x => 0.0, :offset_y => -0.25, :scale_x => 0.65, :scale_y => 0.5, :opacity => 1.0}, duration=0.2)
	end

	def clear_user_object_editor		# TODO: for pointer ?
		if @user_object_editor
			editor = @user_object_editor		# local cache (closures!)
			@user_object_editor.animate({:offset_y => -1.0}, duration=0.3) {
				editor.remove_from_parent!
				show_reopen_button! unless @user_object_editor
			}
		end
		@user_object_editor = nil
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
		elsif @user_object_editor && @user_object_editor.visible?
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

	def close_actors_flyout!
		@actors_flyout.switch_state({:open => :closed}, duration=0.2)
	end

	def open_directors_menu!
		@directors_menu.switch_state({:closed => :open},durection=0.2)
	end

	def close_directors_menu!
		@directors_menu.switch_state({:open => :closed}, duration=0.1)
	end

	def toggle_directors_menu!
		@directors_menu.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	def toggle_actors_flyout!
		@actors_flyout.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	def close_inputs_flyout!
		@variables_flyout.switch_state({:open => :closed}, duration=0.2)
	end

	def toggle_inputs_flyout!
		@variables_flyout.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	def toggle_beat_monitor!
		@beat_monitor.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	def toggle_time_control!
		@time_control.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	def show_reopen_button!
		@reopen_button.switch_state({:closed => :open}, duration=0.2)
	end
	def hide_reopen_button!
		@reopen_button.switch_state({:open => :closed}, duration=0.1)
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

	def chosen_actor_index
		chosen_director.actors.index(chosen_actor)		# possibly nil
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

	def reshow_latest!
		build_editor_for(@user_object, :grab_keyboard_focus => true) if @user_object
	end

	def on_key_press(key)
		#
		# Ctrl key
		#
		if key.control?
			case key
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
			when 'up'
				@directors_menu.open!
				@directors_menu.grab_keyboard_focus!
			when 'down'
				unless hide_something!
					reshow_latest!
				end
			when 'return'
				$application.toggle_fullscreen!
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
				$engine.project.save
				positive_message 'Project Saved'
			when 'f1'
				self.mode = :actor
			when 'f2'
				self.mode = :director
			when 'f3'
				self.mode = :output
			when 'o'
				output_object_counts
			when 'g'
				toggle_gc_timing
			#when 't'
				#ObjectSpace.each_object(Variable) { |variable| puts variable.title }
			end

		#
		# Alt key
		#
		elsif key.alt?
			case key
			when 'down'
				select_next_actor!
				default_focus!
			when 'up'
				select_previous_actor!
				default_focus!
			end

		#
		# no modifier
		#
		else
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

	#
	# Click Response
	#
	def pointer_click_on_nothing(pointer)
		hide_something!
	end

	def pointer_double_click_on_nothing(pointer)
		build_editor_for(@user_object, :grab_keyboard_focus => true) if @user_object
	end

	def active_view
		if mode == :actor
			@actor_view
		elsif mode == :director
			@director_view
		end
	end

	def scroll_up!(pointer)
		return unless (view = active_view)
		view.scroll_up!(pointer)
	end
	def scroll_down!(pointer)
		return unless (view = active_view)
		view.scroll_down!(pointer)
	end
	def scroll_left!(pointer)
		return unless (view = active_view)
		view.scroll_left!(pointer)
	end
	def scroll_right!(pointer)
		return unless (view = active_view)
		view.scroll_right!(pointer)
	end

	#
	# Keyboard interaction
	#
	def keyboard
		@keyboard ||= Keyboard.new(self)
	end

	attr_reader :keyboard_grab_object, :keyboard_grab_proc

	# raw_keyboard_input is called by SDL
	def raw_keyboard_input(value)
		keyboard.raw_keyboard_input(value)
	end

	def grab_keyboard_focus(object=nil, &proc)
		keyboard.grab(object, &proc)
	end

	def cancel_keyboard_focus!
		keyboard.cancel_grab!
	end

	def has_keyboard_focus?(object)
		keyboard.grabbed_by_object?(object)
	end

	def cancel_keyboard_focus_for(object)
		cancel_keyboard_focus! if has_keyboard_focus?(object)
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
end
