require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_hbox', 'gui_vbox', 'gui_list', 'gui_list_with_controls', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider', 'gui_radio_buttons', 'gui_object_renderer', 'gui-ruby/fonts/bitmap-font'

# Addons to existing objects
load_directory(Dir.pwd + '/gui-ruby/addons/', '**.rb')

require 'gui_preferences_box', 'gui_user_object_editor', 'gui_add_window', 'gui_interface'

class String
	boolean_accessor :shift, :control
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

	easy_accessor :camera_x, :output_opacity

	def initialize
		super
		@gui_zoom_out = 1.0		# zoom out for debugging
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

		set(:mode => OUTPUT_MODE, :camera_x => 1.0, :output_opacity => 1.0)

		# Defaults
		@user_object_editors = {}
		@chosen_actor = nil

		#
		# Project Drawer
		#
		self << @project_drawer = GuiHBox.new.set(:scale_x => 0.20, :scale_y => 0.045, :background_image => $engine.load_image('images/drawer-nw.png')).
			add_state(:open, {:hidden => false, :offset_x => -0.40, :offset_y => 0.4775}).
			set_state(:closed, {:hidden => true, :offset_x => -0.60, :offset_y => 0.4775})

			# Close button
			@project_drawer << (@close_project_drawer_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/arrow-left.png')))
			@close_project_drawer_button.on_clicked {
				@project_drawer.switch_state({:open => :closed}, duration=0.1) {
					#@project_menu_button.switch_state({:closed => :open}, duration=0.1)
				}
			}

			# Quit button
			@project_drawer << (@quit_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/exit.png')))
				@quit_button.on_clicked { $application.finished! }

			# Save button
			@project_drawer << @save_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/save.png'))
				@save_button.on_clicked { $engine.save ; positive_message 'Saved successfully.' }

			# Project Effects button
			@project_drawer << (@project_effects_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/arrow-down.png')))
				@project_effects_button.on_clicked { |pointer| build_editor_for($engine.project, :pointer => pointer) }

		# Project corner button
		self << @project_menu_button = GuiButton.new.set(:hotkey => MENU_BUTTON, :scale_x => 0.04, :scale_y => 0.06, :offset_x => -0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png'))
			#.add_state(:closed, {:hidden => true, :offset_x => -0.49, :offset_y => 0.48}).
			#set_state(:open, {:hidden => false, :offset_x => -0.48, :offset_y => 0.47})

		@project_menu_button.on_clicked {
			@project_drawer.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			#@project_menu_button.switch_state({:open => :closed, :closed => :open}, duration=0.2)
		}

		#
		# Director drawer
		#
		self << @directors_drawer = GuiHBox.new.set(:color => [0.1,0.1,0.1,0.5], :scale_x => 0.20, :scale_y => 0.045, :background_image => $engine.load_image('images/drawer-ne.png')).
			add_state(:open, {:hidden => false, :offset_x => 0.40, :offset_y => 0.4775}).
			set_state(:closed, {:hidden => true, :offset_x => 0.60, :offset_y => 0.4775})

			# Radio buttons for @mode		TODO: add director view
			@directors_drawer << GuiRadioButtons.new(self, :mode, [ACTOR_MODE, OUTPUT_MODE]).set(:spacing_x => 1.0)

		# Directors corner button
		self << (@directors_button = GuiButton.new.set(:hotkey => MENU_BUTTON, :scale_x => -0.04, :scale_y => 0.06, :offset_x => 0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png')))
		@directors_button.on_clicked {
			@directors_drawer.switch_state({:open => :closed, :closed => :open}, duration=0.2)
		}

		#
		# Actor drawer
		#
		self << @actor_drawer = GuiHBox.new.set(:color => [0.1,0.1,0.1,0.5], :scale_x => 0.16, :scale_y => 0.045, :background_image => $engine.load_image('images/drawer-se.png')).
			add_state(:open, {:hidden => false, :offset_x => 0.42, :offset_y => -0.4775}).
			set_state(:closed, {:hidden => true, :offset_x => 0.60, :offset_y => -0.4775})

			# New Actor button(s)
			@actor_drawer << (@new_actor_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/new.png')))
			@new_actor_button.on_clicked { @actors_list.add_after_selection(ActorStar.new) }

		# Actor list
		self << @actors_list = GuiListWithControls.new($engine.project.actors).set(:scroll_wrap => true, :scale_x => 0.12, :scale_y => 0.9, :offset_y => -0.05, :spacing_y => -1.0).
			add_state(:open, {:offset_x => 0.44, :offset_y => 0.0, :hidden => false}).
			set_state(:closed, {:offset_x => 0.56, :offset_y => 0.0, :hidden => true})

		# Actors corner button
		self << (@actors_button = GuiButton.new.set(:hotkey => ACTORS_BUTTON, :scale_x => -0.04, :scale_y => -0.06, :offset_x => 0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png')))
		@actors_button.on_clicked {
			@actors_list.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@actor_drawer.switch_state({:open => :closed, :closed => :open}, duration=0.2)
		}

		#
		# Events/Variables drawer
		#
		self << @events_drawer = GuiHBox.new.set(:color => [0.1,0.1,0.1,0.5], :scale_x => 0.16, :scale_y => 0.045, :background_image => $engine.load_image('images/drawer-sw.png')).
			add_state(:open, {:hidden => false, :offset_x => -0.42, :offset_y => -0.4775}).
			set_state(:closed, {:hidden => true, :offset_x => -0.60, :offset_y => -0.4775})

			# Close button
			@events_drawer << (@close_events_drawer_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/arrow-left.png')))
			@close_events_drawer_button.on_clicked {
				@events_list.switch_state({:open => :closed}, duration=0.2)
				@variables_list.switch_state({:open => :closed}, duration=0.2)
				#@events_button.switch_state({:closed => :open}, duration=0.2)
				@events_drawer.switch_state({:open => :closed}, duration=0.2)
			}

			# New Event button
			@events_drawer << (@new_event_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/new.png')))
			@new_event_button.on_clicked { |pointer| @events_list.add_after_selection(event = Event.new) ; build_editor_for(event, :pointer => pointer) }

			# New Variable button
			@events_drawer << (@new_variable_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/new.png')))
			@new_variable_button.on_clicked { |pointer| @variables_list.add_after_selection(variable = Variable.new) ; build_editor_for(variable, :pointer => pointer) }

		# Events list
		self << @events_list = GuiListWithControls.new($engine.project.events).set(:scale_x => 0.12, :scale_y => 0.45, :offset_y => 0.22, :item_aspect_ratio => 3.2, :hidden => true, :spacing_y => -1.0).
			add_state(:open, {:hidden => false, :offset_x => -0.44, :opacity => 1.0}).
			set_state(:closed, {:offset_x => -0.6, :opacity => 0.0, :hidden => true})

		# Variables list
		self << @variables_list = GuiListWithControls.new($engine.project.variables).set(:scale_x => 0.12, :scale_y => 0.45, :offset_y => -0.23, :item_aspect_ratio => 3.2, :hidden => true, :spacing_y => -1.0).
			add_state(:open, {:hidden => false, :offset_x => -0.44, :opacity => 1.0}).
			set_state(:closed, {:offset_x => -0.6, :opacity => 0.0, :hidden => true})

		# Events/Variables corner button
		self << @events_button = GuiButton.new.set(:hotkey => EVENTS_BUTTON, :scale_x => 0.04, :scale_y => -0.06, :background_image => $engine.load_image('images/corner.png')).
			add_state(:closed, {:hidden => true, :offset_x => -0.55, :offset_y => -0.53}).
			set_state(:open, {:hidden => false, :offset_x => -0.48, :offset_y => -0.47})

		@events_button.on_clicked {
			#@events_button.switch_state({:open => :closed}, duration=0.2)
			@events_drawer.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@variables_list.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@events_list.switch_state({:open => :closed, :closed => :open}, duration=0.2)
		}

		#
		# User Object Editor
		#
		self << @recall_user_object_editor_button = GuiButton.new.set(:offset_y => -0.495, :scale_x => 0.09, :scale_y => 0.02, :background_scale_y => -1.0, :background_image => $engine.load_image('images/drawer-n.png'))
		@recall_user_object_editor_button.on_clicked { |pointer|
			build_editor_for(@chosen_actor, :pointer => pointer)
		}
		self << @user_object_editor_container = GuiBox.new

		#
		# OVERLAY LEVEL (things above this line are obscured while overlay is showing)
		#
		self << @overlay = GuiObject.new.set(:color => [0,0,0]).
			add_state(:open, {:opacity => 1.0, :hidden => false}).
			set_state(:closed, {:opacity => 0.0, :hidden => true})

		# Main menu
		self << @main_menu = MainMenu.new.set(:hidden => true)

		# Message Bar
		self << (@message_bar = GuiMessageBar.new.set(:offset_x => 0.02, :offset_y => 0.5 - 0.05, :scale_x => 0.32, :scale_y => 0.05))

		# Beat Monitor
		self << @beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:scale_x => 0.10, :scale_y => 0.02, :background_scale_x => 1.2, :background_scale_y => 1.2, :background_image => $engine.load_image('images/drawer-n.png')).
			add_state(:closed, {:offset_x => 0.0, :offset_y => 0.55, :hidden => true}).
			set_state(:open, {:offset_x => 0.0, :offset_y => 0.49, :hidden => false})
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
				with_multiplied_alpha(output_opacity) {
					with_translation(1.0, 0.0) {
						yield
					}
				}
			end
		}
	end

	def gui_render!
		with_scale(@gui_zoom_out * ($env[:enter] + $env[:exit]).scale(1.5, 1.0)) {
			with_alpha(($env[:enter] + $env[:exit]).scale(0.0, 1.0)) {
				super
			}
		}
	end

	def on_key_press(value)
		if value.control?
			case value
			when 'b'
				@beat_monitor.switch_state({:open => :closed, :closed => :open}, duration=0.2)

			when 'n'
				case mode
				when ACTOR_MODE
					# TODO not working @chosen_actor.build_add_child_window_for_pointer(nil) if @chosen_actor
				when DIRECTOR_MODE
					# TODO
				end
			when 'r'
				$engine.reload
			end
		else
			case value
			when 'escape'
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
			if user_object.is_a? Actor
				self.mode = ACTOR_MODE		# TODO: make this an option?
				@chosen_actor = user_object
			end
			return nil
		else
			if user_object.is_a?(ParentUserObject) || user_object.is_a?(Project)		# TODO: responds_to? :effects ?
				if user_object.is_a? Actor
					# Rule: cannot view one actor (in actor-mode) while editing another
					if @mode == ACTOR_MODE
						@chosen_actor = user_object
					end
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
				return nil
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

	def hide_something!
	end
end
