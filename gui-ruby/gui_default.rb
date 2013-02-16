require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_hbox', 'gui_vbox', 'gui_list', 'gui_list_with_controls', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider', 'gui_radio_buttons', 'gui_object_renderer'
require 'gui-ruby/fonts/bitmap-font'

# Addons to existing objects
load_directory(Dir.pwd + '/gui-ruby/addons/', '**.rb')

require 'gui_preferences_box'
require 'gui_user_object_editor'
require 'gui_add_window'
require 'gui_interface'

class String
	boolean_accessor :shift
	boolean_accessor :control
end

class MainMenu < GuiBox
	def initialize
		super
		create!
	end

	def create!
		self << GuiObject.new.set(:color => [0.5,0.5,0.5,0.5])
		self << GuiButton.new.set(:scale_x => 0.2, :scale_y => 0.1, :offset_x => -0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/buttons/menu.png'))
		self << GuiButton.new.set(:scale_x => 0.2, :scale_y => 0.1, :offset_x => 0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/buttons/play.png'))
	end
end

class ActorClassRenderer < GuiObject
	def initialize(klass)
		@object = klass.new
	end

	def gui_render!
		with_positioning {
			@object.render!
		}
	end
end

class GuiDefault < GuiInterface
	pipe [:positive_message, :negative_message], :message_bar

	ACTOR_MODE, DIRECTOR_MODE, OUTPUT_MODE = 1, 2, 3

	# hardcoded SDL keys
	ESCAPE_KEY						= 'escape'

	# hardcoded Luz keys
	MENU_BUTTON						= ''
	SAVE_BUTTON						= ''

	EVENTS_BUTTON					= 'Keyboard / F1'
	VARIABLES_BUTTON			= 'Keyboard / F2'

	ACTORS_BUTTON					= 'Keyboard / F8'
	#THEMES_BUTTON					= 'Keyboard / F5'
	#CURVES_BUTTON					= 'Keyboard / F6'
	PREFERENCES_BUTTON		= 'Keyboard / F12'

	callback :keypress

	easy_accessor :camera_x

	def initialize
		super
		create!
	end

	def reload_notify
		clear!
		create!
	end

	#
	# Building the GUI
	#
	# Minimal start for a new object: self << GuiObject.new.set(:scale_x => 0.1, :scale_y => 0.1)
	def create!
		# Remember: this is drawn first-to-last
		set(:camera_x => 0.0)

		#
		# Project Drawer
		#
		self << @project_drawer = GuiHBox.new.set(:scale_x => 0.15, :scale_y => 0.05).
			add_state(:open, {:hidden => false, :offset_x => -0.40, :offset_y => 0.475}).
			set_state(:closed, {:hidden => true, :offset_x => -0.60, :offset_y => 0.475})

			# Save Button
			@project_drawer << @save_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/save.png'))
				@save_button.on_clicked { $engine.save ; positive_message 'Saved successfully.' }

			# Quit Button
			@project_drawer << (@quit_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/exit.png')))
				@quit_button.on_clicked { $application.finished! }

			# Project Effects Button
			@project_drawer << (@project_effects_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/down.png')))
				@project_effects_button.on_clicked { |pointer| build_editor_for($engine.project, :pointer => pointer) }

		# Project button to show project drawer
		self << (@project_menu_button = GuiButton.new.set(:hotkey => MENU_BUTTON, :scale_x => 0.04, :scale_y => 0.06, :offset_x => -0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png')))
		@project_menu_button.on_clicked { @project_drawer.switch_state({:open => :closed, :closed => :open}, duration=0.2) }

		#
		# Actor Drawer
		#
		self << @actor_drawer = GuiHBox.new.set(:color => [0.1,0.1,0.1,0.5], :scale_x => 0.15, :scale_y => 0.05).
			add_state(:open, {:hidden => false, :offset_x => 0.40, :offset_y => -0.475}).
			set_state(:closed, {:hidden => true, :offset_x => 0.60, :offset_y => -0.475})

			# New Actor Button(s)
			@actor_drawer << (@new_actor_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/new.png')))
			@new_actor_button.on_clicked { @actors_list.add_after_selection(ActorStar.new) }

		# Actor list
		self << @actors_list = GuiListWithControls.new($engine.project.actors).set(:scroll_wrap => true, :scale_x => 0.12, :scale_y => 0.8, :spacing_y => -1.0).
			add_state(:open, {:offset_x => 0.44, :offset_y => 0.0, :hidden => false}).
			set_state(:closed, {:offset_x => 0.56, :offset_y => 0.0, :hidden => true})

		self << (@actors_button = GuiButton.new.set(:hotkey => ACTORS_BUTTON, :scale_x => -0.04, :scale_y => -0.06, :offset_x => 0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png')))
		@actors_button.on_clicked {
			@actors_list.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@actor_drawer.switch_state({:open => :closed, :closed => :open}, duration=0.2)
		}

		#
		# Events/Variables Drawer
		#
		self << @events_drawer = GuiHBox.new.set(:color => [0.1,0.1,0.1,0.5], :scale_x => 0.15, :scale_y => 0.05).
			add_state(:open, {:hidden => false, :offset_x => -0.40, :offset_y => -0.475}).
			set_state(:closed, {:hidden => true, :offset_x => -0.60, :offset_y => -0.475})

			# New Event Button
			@events_drawer << (@new_event_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/new.png')))
			@new_event_button.on_clicked { @events_list.add_after_selection(Event.new) }

		self << @events_list = GuiListWithControls.new($engine.project.events).set(:scale_x => 0.12, :scale_y => 0.45, :offset_y => 0.22, :item_aspect_ratio => 3.2, :hidden => true, :spacing_y => -1.0).
			add_state(:open, {:hidden => false, :offset_x => -0.44, :opacity => 1.0}).
			set_state(:closed, {:offset_x => -0.6, :opacity => 0.0, :hidden => true})

		self << @variables_list = GuiListWithControls.new($engine.project.variables).set(:scale_x => 0.12, :scale_y => 0.45, :offset_y => -0.23, :item_aspect_ratio => 3.2, :hidden => true, :spacing_y => -1.0).
			add_state(:open, {:hidden => false, :offset_x => -0.44, :opacity => 1.0}).
			set_state(:closed, {:offset_x => -0.6, :opacity => 0.0, :hidden => true})

		self << (@events_button = GuiButton.new.set(:hotkey => EVENTS_BUTTON, :scale_x => 0.04, :scale_y => -0.06, :offset_x => -0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png')))
		@events_button.on_clicked {
			@events_drawer.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@variables_list.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@events_list.switch_state({:open => :closed, :closed => :open}, duration=0.2)
		}

		#
		# Director Drawer
		#
		self << (@directors_button = GuiButton.new.set(:hotkey => MENU_BUTTON, :scale_x => -0.04, :scale_y => 0.06, :offset_x => 0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png')))

		# Radio buttons for @mode		TODO: add director view
		self << GuiRadioButtons.new(self, :mode, [ACTOR_MODE, OUTPUT_MODE]).set(:offset_x => 0.35, :offset_y => 0.485, :scale_x => 0.06, :scale_y => 0.03, :spacing_x => 1.0)

		self << (@user_object_editor_container = GuiBox.new)

		# OVERLAY LEVEL (things above this line are obscured while overlay is showing)
		self << (@overlay = GuiObject.new.set(:color => [0,0,0], :opacity => 0.0, :hidden => true))

		# Main menu
		@main_menu = MainMenu.new.set(:hidden => true, :scale_x => 0.0, :scale_y => 0.6).animate({:scale_x => 0.3, :scale_y => 0.65}, duration=0.1)
		self << @main_menu

		# Message Bar
		self << (@message_bar = GuiMessageBar.new.set(:offset_x => 0.02, :offset_y => 0.5 - 0.05, :scale_x => 0.32, :scale_y => 0.05))

		# Beat Monitor
		self << (@beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:offset_y => 0.49, :scale_x => 0.12, :scale_y => 0.02, :spacing_x => 1.0))

		# Preferences Box
		#self << (@preferences_box = GuiPreferencesBox.new.build.set(:scale_x => 0.22, :scale_y => 0.4, :offset_x => 0.4, :offset_y => -0.3, :opacity => 0.0, :hidden => true))
		#self << (@preferences_button = GuiButton.new.set(:hotkey => PREFERENCES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.50, :offset_y => -0.50, :color => [0.5,1.0,0.5,1.0], :background_image => $engine.load_image('images/buttons/menu.png')))
		#@preferences_button.on_clicked { toggle_preferences_box! }

		# Defaults
		@user_object_editors = {}
		@chosen_actor = nil
		self.mode = OUTPUT_MODE
		self.camera_x = 1.0
	end

	def hide_main_menu
		return false if @main_menu.hidden?
		hide_overlay!
		@main_menu.animate({:scale_x => 0.0, :scale_y => 0.0}, duration=0.1) { @main_menu.set(:hidden => true) }
		true
	end

	def show_main_menu
		show_overlay!
		@main_menu.set({:scale_x => 0.0, :scale_y => 0.0, :hidden => false}).animate({:scale_x => 0.3, :scale_y => 0.65}, duration=0.1)
	end

	def toggle_main_menu!
		if @overlay
			hide_main_menu
		else
			show_main_menu
		end
	end

	#
	# Overlay
	#
	def show_overlay!
		@overlay.set(:hidden => false).animate({:opacity => 0.8}, duration=0.5)
	end

	def hide_overlay!
		@overlay.animate({:opacity => 0.0}, duration=0.25) { @overlay.set(:hidden => true) }
	end

	#
	# Mode switching
	#
	attr_reader :mode
	def mode=(mode)
		return if mode == @mode

		@mode = mode
		after_mode_change
	end

	def after_mode_change
		case @mode
		when ACTOR_MODE
			animate(:camera_x, 0.0, 0.2)
#		when DIRECTOR_MODE
#			animate(:camera_x, 1.0, 0.2)
		when OUTPUT_MODE
			animate(:camera_x, 1.0, 0.2)
		end
	end

	def render
		with_translation(-camera_x, 0.0) {
			if camera_x < 1.0
				@chosen_actor.render! if @chosen_actor
			end

			# Render output view
			if camera_x > 0.0 && camera_x < 2.0
				with_translation(1.0, 0.0) {
					yield
				}
			end
		}
	end

	def gui_render!
		with_scale(($env[:enter] + $env[:exit]).scale(1.5, 1.0)) {
			with_alpha(($env[:enter] + $env[:exit]).scale(0.0, 1.0)) {
				super
			}
		}
	end

	TOGGLE_BEAT_MONITOR_KEY = 'b'
	NEW_KEY = 'n'
	def on_key_press(value)
		if value.control?
			case value
			when TOGGLE_BEAT_MONITOR_KEY
				# TODO
				positive_message 'toggle beat monitor'
			when NEW_KEY
				case mode
				when ACTOR_MODE
					# TODO not working @chosen_actor.build_add_child_window_for_pointer(nil) if @chosen_actor
				when DIRECTOR_MODE
					# TODO
				end
			end
		else
			case value
			when ESCAPE_KEY
				hide_something!
			end
		end
	end

	#
	# Keyboard grabbing
	#
	def build_editor_for(user_object, options)
		pointer = options[:pointer]
		editor = @user_object_editors[user_object]

		if editor && !editor.hidden?
			# was already visible... ...hide self towards click spot
			@user_object_editor_container.bring_to_top(editor)

			if user_object.is_a? Actor
				self.mode = ACTOR_MODE		# TODO: make this an option?
				@chosen_actor = user_object
			end

#			editor.animate({:offset_x => pointer.x, :offset_y => pointer.y, :scale_x => 0.0, :scale_y => 0.0, :opacity => 0.2}, duration=0.2) {
#				editor.remove_from_parent!		# trashed forever! (no cache)
#				@user_object_editors.delete(user_object)
#			}
			return
		else
			if user_object.is_a?(ParentUserObject) || user_object.is_a?(Project)
				# Auto-switch to actor view
				if user_object.is_a? Actor
					# Rule: cannot view one actor (in actor-mode) while editing another
					if @mode == ACTOR_MODE
						@chosen_actor = user_object
					end
#					@mode = ACTOR_MODE		# TODO: make this an option?
#					@chosen_actor = user_object
#					close_actor_list!		# TODO: make this an option?
				elsif user_object.is_a? Director
					# TODO
				end

				clear_editors!		# only support one for now

				editor = create_user_object_editor_for_pointer(user_object, pointer, options)
				@user_object_editors[user_object] = editor
				@user_object_editor_container << editor

				return editor
			else
				# tell editor its child was clicked (this is needed due to non-propagation of click messages: the user object gets notified, it tells us)
				parent = @user_object_editors.keys.find { |uo| uo.effects.include? user_object }		# TODO: hacking around children not knowing their parents for easier puppetry
				parent.on_child_user_object_selected(user_object) if parent		# NOTE: can't click a child if parent is not visible, but the 'if' doesn't hurt
				return
			end
		end
	end

	def pointer_click_on_nothing(pointer)
		hide_something!
	end

	#
	# Utility methods
	#
	def create_user_object_editor_for_pointer(user_object, pointer, options)
		GuiUserObjectEditor.new(user_object, {:scale_x => 0.3, :scale_y => 0.05}.merge(options)).
			set({:offset_x => pointer.x, :offset_y => pointer.y, :opacity => 1.0, :scale_x => 0.0, :scale_y => 0.0, :hidden => false}).
			animate({:offset_x => 0.0, :offset_y => -0.25, :scale_x => 0.65, :scale_y => 0.5, :opacity => 1.0}, duration=0.2)
	end

	def clear_editors!
		@user_object_editors.each { |user_object, editor|
			editor.animate({:offset_y => editor.offset_y - 0.5}, duration=0.2) {
				editor.remove_from_parent!		# trashed forever! (no cache)
			}
		}
		@user_object_editors.clear
	end

	#
	# Preferences Box
	#
	def show_preferences_box! ; @preferences_box.set(:hidden => false, :opacity => 0.0).animate({:opacity => 1.0, :offset_x => 0.38, :offset_y => -0.3}, duration=0.2) ; end
	def hide_preferences_box! ; @preferences_box.animate({:opacity => 0.0, :offset_x => 0.6, :offset_y => -0.6}, duration=0.25) { @preferences_box.set_hidden(true) } ; end
	def toggle_preferences_box!
		if @preferences_box.hidden?		# TODO: this is not a good way to toggle
			show_preferences_box!
		else
			hide_preferences_box!
		end
	end

=begin
	def toggle_curves_list!
		if @curves_list.hidden?
			@curves_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
		else
			@curves_list.animate(:offset_y, 0.5, duration=0.25) { @curves_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
		end
	end

	def toggle_themes_list!
		if @themes_list.hidden?
			@themes_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
		else
			@themes_list.animate(:offset_y, 0.5, duration=0.25) { @themes_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
		end
	end
=end

	def toggle_variables_list!
		if @variables_list.hidden?
			@variables_list.set(:hidden => false, :offset_x => -0.6, :opacity => 0.0).animate({:offset_x => -0.44, :opacity => 1.0}, duration=0.2)
		else
			@variables_list.animate(:offset_x, -0.6, duration=0.25) { @variables_list.set_hidden(true) }
		end
	end

	def hide_something!
		if @main_menu && !@main_menu.hidden?
			hide_main_menu

		elsif @preferences_box && !@preferences_box.hidden?
			toggle_preferences_box!

		elsif @actors_list && !@actors_list.hidden?
			toggle_actors_list!

		elsif @themes_list && !@themes_list.hidden?
			toggle_themes_list!

		elsif @curves_list && !@curves_list.hidden?
			toggle_curves_list!

		elsif @variables_list && !@variables_list.hidden?
			toggle_variables_list!
			#elsif @events_list && !@events_list.hidden?
			toggle_events_list!
		else
			return false
			# TODO: close editor interface?
		end
		return true
	end
end
