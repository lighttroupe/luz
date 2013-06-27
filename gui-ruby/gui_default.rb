multi_require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_hbox', 'gui_vbox', 'gui_list', 'gui_scrollbar', 'gui_list_with_controls', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider', 'gui_radio_buttons', 'gui_object_renderer', 'gui-ruby/fonts/bitmap-font', 'history', 'gui_history_buttons', 'gui_main_menu'

# Addons to existing objects
load_directory(Dir.pwd + '/gui-ruby/addons/', '**.rb')

multi_require 'gui_actor_view', 'gui_director_view', 'gui_preferences_box', 'gui_user_object_editor', 'gui_add_window', 'gui_interface', 'gui_actor_class_button', 'gui_director_menu', 'gui_actors_flyout', 'gui_variables_flyout'

class GuiDefault < GuiInterface
	pipe [:positive_message, :negative_message], :message_bar

	ACTOR_MODE, DIRECTOR_MODE, OUTPUT_MODE = 1, 2, 3

	# hardcoded Luz keys
	MENU_BUTTON						= ''
	SAVE_BUTTON						= ''

	EVENTS_BUTTON					= 'Keyboard / F1'
	#VARIABLES_BUTTON			= 'Keyboard / F2'

	ACTORS_BUTTON					= 'Keyboard / F8'
	#THEMES_BUTTON				= 'Keyboard / F5'
	#CURVES_BUTTON				= 'Keyboard / F6'
	#PREFERENCES_BUTTON		= 'Keyboard / F12'
	PLAY_KEY		= 'Keyboard / F12'

	callback :keypress

	easy_accessor :camera_x, :output_opacity

	def initialize
		super
		@gui_zoom_out = 1.0		# zoom out for debugging
		@history = History.new
		@history.on_navigation { |user_object|
			build_editor_for(user_object, :history => false)
		}
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

		#
		# Actors / Directors flyout
		#
		self << @actors_flyout = GuiActorsFlyout.new.set(:scale_x => 0.12, :scale_y => 1.0, :offset_x => 0.5 - 0.06).		# TODO: background image?
			add_state(:open, {:offset_x => 0.44, :hidden => false}).
			set_state(:closed, {:offset_x => 0.56, :hidden => true})

		# Directors corner button (top right)
		self << (@directors_button = GuiButton.new.set(:hotkey => MENU_BUTTON, :scale_x => -0.04, :scale_y => 0.06, :offset_x => 0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png')))
		@directors_button.on_clicked {
			@director_menu.switch_state({:closed => :open},durection=0.4)
		}

		# Actors corner button (bottom right)
		self << (@actors_button = GuiButton.new.set(:hotkey => ACTORS_BUTTON, :scale_x => -0.04, :scale_y => -0.06, :offset_x => 0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png')))
		@actors_button.on_clicked {
			toggle_actors_flyout!
		}

		#
		# Events / Variables flyout
		#
		self << @variables_flyout = GuiVariablessFlyout.new.set(:scale_x => 0.12, :scale_y => 1.0, :offset_x => -0.44).
			add_state(:open, {:hidden => false, :offset_x => -0.44}).
			set_state(:closed, {:hidden => true, :offset_x => -0.56})

		# Events/Variables corner button (bottom left)
		self << @events_button = GuiButton.new.set(:hotkey => EVENTS_BUTTON, :scale_x => 0.04, :scale_y => -0.06, :background_image => $engine.load_image('images/corner.png')).
			add_state(:closed, {:hidden => true, :offset_x => -0.55, :offset_y => -0.53}).
			set_state(:open, {:hidden => false, :offset_x => -0.48, :offset_y => -0.47})

		@events_button.on_clicked {
			toggle_inputs_flyout!
		}

		# Project corner button (upper left)
		self << @project_menu_button = GuiButton.new.set(:hotkey => MENU_BUTTON, :scale_x => 0.04, :scale_y => 0.06, :offset_x => -0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png'))
		@project_menu_button.on_clicked {
			@overlay.switch_state({:closed => :open}, duration=0.4)
			@main_menu.switch_state({:closed => :open}, duration=0.2)
		}

			#@save_button.on_clicked { $engine.save ; positive_message 'Saved successfully.' }
			#@project_effects_button.on_clicked { |pointer| build_editor_for($engine.project, :pointer => pointer) }


		#
		# User Object Editor
		#
		self << @user_object_editor_container = GuiBox.new

=begin		History feature disabled in favor of up/down to move between actors
		self << @toggle_user_object_editor_button = GuiButton.new.set(:offset_y => -0.495, :scale_x => 0.09, :scale_y => 0.02, :background_scale_y => -1.0, :background_image => $engine.load_image('images/drawer-n.png'))
		@toggle_user_object_editor_button.on_clicked { |pointer|
			if @user_object_editor_container.empty?
				build_editor_for(@history.current, :pointer => pointer)
			else
				clear_editors!
			end
		}

		self << @back_button = GuiBackButton.new(@history).set(:offset_x => -0.04, :offset_y => -0.495, :scale_x => 0.03, :scale_y => 0.02, :background_scale_y => -1.0, :background_image => $engine.load_image('images/buttons/arrow-left.png'))
		self << @forward_button = GuiForwardButton.new(@history).set(:offset_x => 0.04, :offset_y => -0.495, :scale_x => -0.03, :scale_y => 0.02, :background_scale_y => -1.0, :background_image => $engine.load_image('images/buttons/arrow-left.png'))
=end

		#
		# OVERLAY LEVEL (things above this line are obscured while overlay is showing)
		#
		self << @overlay = GuiObject.new.set(:background_image => $engine.load_image('images/overlay.png')).
			add_state(:open, {:opacity => 1.0, :hidden => false}).
			set_state(:closed, {:opacity => 0.0, :hidden => true})

		# Main menu
		self << @main_menu = GuiMainMenu.new.set(:opacity => 0.0, :hidden => true).
			add_state(:open, {:scale_x => 1.0, :opacity => 1.0, :hidden => false}).
			set_state(:closed, {:scale_x => 2.0, :opacity => 0.0, :hidden => true})

#		self << @main_menu = GuiMainMenu.new.set(:hidden => true, :scale_y => 0.7).
#			add_state(:open, {:scale_x => 0.35, :hidden => false}).
#			set_state(:closed, {:scale_x => 0.0, :hidden => true})

		@main_menu.on_close {
			@main_menu.switch_state({:open => :closed}, duration=0.1)
			@overlay.switch_state({:open => :closed}, duration=0.2)
		}

		@main_menu.on_save {
			$engine.save
			positive_message 'Saved successfully.'
		}

		# Director Grid popup
		self << @director_menu = GuiDirectorMenu.new($engine.project.directors).
			add_state(:open, {:scale_x => 1.0, :scale_y => 1.0, :opacity => 1.0, :hidden => false}).
			set_state(:closed, {:scale_x => 1.1, :scale_y => 1.1, :offset_y => 0.0,:hidden => true})

		# Message Bar
		self << (@message_bar = GuiMessageBar.new.set(:offset_x => 0.02, :offset_y => 0.5 - 0.05, :scale_x => 0.32, :scale_y => 0.05))

		# Beat Monitor
		self << @beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:scale_x => 0.10, :scale_y => 0.02, :background_scale_x => 1.2, :background_scale_y => 1.2, :background_image => $engine.load_image('images/drawer-n.png')).
			add_state(:closed, {:offset_x => 0.0, :offset_y => 0.55, :hidden => true}).
			set_state(:open, {:offset_x => 0.0, :offset_y => 0.49, :hidden => false})

		self << @directors_list = GuiListWithControls.new([]).set(:hidden => true)

		@actor_view = GuiActorView.new
		@director_view = GuiDirectorView.new

		#
		# 
		#
		set_initial_state
	end

	def set_initial_state
		@user_object_editors = {}
		@actor_view.actor = nil

		# Auto-select first director
		director = $engine.project.directors.first

		# Hack to load project file format 1
		director.actors = $engine.project.actors if director.actors.empty? and not $engine.project.actors.empty?

		self.chosen_director = director

		self.mode = OUTPUT_MODE
		self.output_opacity = 1.0
	end

# TODO: make private?

	def close_actors_flyout!
		@actors_flyout.switch_state({:open => :closed}, duration=0.2)
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

	def trash!(user_object)
		@actors_flyout.remove(user_object)
		@actor_view.actor = nil if @actor_view.actor == user_object

		@directors_list.remove(user_object)
		@director_view.director = nil if @director_view.director == user_object

		@variables_flyout.remove(user_object)

		@history.remove(user_object)

		clear_editors! if @user_object_editors[user_object]
	end

	def chosen_director
		@director_view.director
	end

	def chosen_director=(director)
		@director_view.director = director
		@actors_flyout.actors = director.actors

		self.mode = DIRECTOR_MODE

		@actor_view.actor = director.actors.first
		build_editor_for(@actor_view.actor) if self.mode == ACTOR_MODE
	end

	#
	# Mode switching
	#
	attr_reader :mode
	def mode=(mode)
		return if mode == @mode
		@mode = mode
		# TODO: animate?
	end

	def render
		case @mode
		when ACTOR_MODE
			@actor_view.gui_render!

		when DIRECTOR_MODE
			@director_view.gui_render!

		when OUTPUT_MODE
			with_multiplied_alpha(output_opacity) {
				yield
			}
		end
	end

	def actor_view_background_image
		unless @actor_view_background
			@actor_view_background = $engine.load_image('images/background.png')
			@actor_view_background.set_texture_options(:no_smoothing => true)
		end
		@actor_view_background
	end

	def gui_render!
		with_scale(@gui_zoom_out * ($env[:enter] + $env[:exit]).scale(1.5, 1.0)) {
			with_alpha(($env[:enter] + $env[:exit]).scale(0.0, 1.0)) {
				super
			}
		}
	end

	def on_key_press(value)
		#
		# Ctrl key
		#
		if value.control?
			case value
			when 'b'
				@beat_monitor.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			when 'o'
				output_object_counts
			when 'n'
				positive_message 'TODO: add actor'
			when 'm'
				positive_message 'TODO: add effect'
			when 'r'
				$engine.reload
			when 'f11'
				output_gc_counts
			when 'f12'
				toggle_gc_timing
			end

		#
		# Alt key
		#
		elsif value.alt?
			case value
			when 'right'
				#@forward_button.click(nil)
			when 'left'
				#@back_button.click(nil)
			when 'down'
				select_next_actor!
			when 'up'
				select_previous_actor!
			end

		#
		# no modifier
		#
		else
			case value
			when 'escape'
				hide_something!
			else
				route_keypress_to_selected_widget(value)
			end
		end
	end

	def route_keypress_to_selected_widget(value)
	end

	def chosen_actor_index
		@director_view.director.actors.index(@actor_view.actor)
	end

	def select_previous_actor!
		return unless @actor_view.actor && @director_view.director && @director_view.director.actors.size > 0
		index = ((chosen_actor_index || 1) - 1) % @director_view.director.actors.size
		build_editor_for(@director_view.director.actors[index])
	end

	def select_next_actor!
		return unless @actor_view.actor && @director_view.director && @director_view.director.actors.size > 0
		index = ((chosen_actor_index || -1) + 1) % @director_view.director.actors.size
		build_editor_for(@director_view.director.actors[index])
	end

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

	def handle_first_click_on_user_object(user_object, options)
		pointer = options[:pointer]

		if user_object == chosen_director
			self.mode = DIRECTOR_MODE
			@director_menu.switch_state({:open => :closed}, duration=0.1)

		elsif user_object.is_a?(ParentUserObject) || user_object.is_a?(Project)		# TODO: responds_to? :effects ?
			#
			# Browser-like history of edited objects
			#
			unless options.delete(:history) == false
				@history.remove(user_object)		# is this correct?  browsers don't do this.
				@history.add(user_object) if suitable_for_history?(user_object)
			end

			#
			# Select / show object
			#
			clear_editors!		# only support one for now

			if user_object.is_a?(Director) && @director_menu.visible?
				# selecting a director
				self.chosen_director = user_object
				@director_menu.switch_state({:open => :closed}, duration=0.1)
			else
				if user_object.is_a? Actor
					if @mode == ACTOR_MODE
						# Rule: cannot view one actor (in actor-mode) while editing another
						@actor_view.actor = user_object
					end
				end

				editor = create_user_object_editor_for_pointer(user_object, pointer || Vector3.new(0.0,-0.5), options)
				@user_object_editors[user_object] = editor
				@user_object_editor_container << editor

				return editor
			end
		else
			# tell editor its child was clicked (this is needed due to non-propagation of click messages: the user object gets notified, it tells us)
			parent = @user_object_editors.keys.find { |uo| uo.effects.include? user_object }		# TODO: hacking around children not knowing their parents for easier puppetry
			parent.on_child_user_object_selected(user_object) if parent		# NOTE: can't click a child if parent is not visible, but the 'if' doesn't hurt
			return nil
		end
	end

	def handle_second_click_on_user_object(user_object, options)
		pointer = options[:pointer]

		if user_object.is_a? Actor
			if (self.mode == ACTOR_MODE && @actor_view.actor == user_object)
				@actors_flyout.animate_to_state(:closed, duration=0.1)
			else
				@actor_view.actor = user_object
				self.mode = ACTOR_MODE		# TODO: make this an option?
			end
		elsif user_object.is_a? Project
			clear_editors!

		elsif user_object.is_a?(Variable) or user_object.is_a?(Event)
			close_inputs_flyout!

		elsif user_object.is_a?(Director)
			self.chosen_director = user_object
			@director_menu.switch_state({:open => :closed}, duration=0.1)
		end
	end

	#
	#
	#
	def build_editor_for(user_object, options={})
		return unless user_object

		editor = @user_object_editors[user_object]

		# Single-editor interface: is an editor for this object already showing?
		if editor && !editor.hidden?
			handle_second_click_on_user_object(user_object, options)
		else
			handle_first_click_on_user_object(user_object, options)
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
		if @variables_flyout.visible? or @actors_flyout.visible?
			close_inputs_flyout!
			close_actors_flyout!

		else
			# ?
		end
	end

	def suitable_for_history?(object)
		[Actor, Variable, Event].any? { |klass| object.is_a? klass }
	end
end
