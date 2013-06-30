multi_require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_hbox', 'gui_vbox', 'gui_list', 'gui_scrollbar', 'gui_list_with_controls', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider', 'gui_radio_buttons', 'gui_object_renderer', 'gui-ruby/fonts/bitmap-font', 'history', 'gui_history_buttons', 'gui_main_menu'

# Addons to existing objects
load_directory(Dir.pwd + '/gui-ruby/addons/', '**.rb')

multi_require 'gui_actor_view', 'gui_director_view', 'gui_preferences_box', 'gui_user_object_editor', 'gui_add_window', 'gui_interface', 'gui_actor_class_button', 'gui_director_menu', 'gui_actors_flyout', 'gui_variables_flyout', 'keypress_router'

class GuiDefault < GuiInterface
	pipe [:positive_message, :negative_message], :message_bar

	ACTOR_MODE, DIRECTOR_MODE, OUTPUT_MODE = 1, 2, 3

	callback :keypress

	attr_accessor :mode

	def initialize
		super
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
		@keypress_router = KeypressRouter.new(self)

		#
		# Actors / Directors flyout
		#
		self << @actors_flyout = GuiActorsFlyout.new.set(:scale_x => 0.12, :scale_y => 1.0, :offset_x => 0.5 - 0.06).
			add_state(:open, {:offset_x => 0.44, :hidden => false}).
			set_state(:closed, {:offset_x => 0.56, :hidden => true})

		# Directors corner button (top right)
		self << (@directors_button = GuiButton.new.set(:scale_x => -0.04, :scale_y => 0.06, :offset_x => 0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png')))
		@directors_button.on_clicked {
			@director_menu.switch_state({:closed => :open},durection=0.4)
		}

		# Actors corner button (bottom right)
		self << (@actors_button = GuiButton.new.set(:scale_x => -0.04, :scale_y => -0.06, :offset_x => 0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png')))
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
		self << @events_button = GuiButton.new.set(:scale_x => 0.04, :scale_y => -0.06, :background_image => $engine.load_image('images/corner.png')).
			add_state(:closed, {:hidden => true, :offset_x => -0.55, :offset_y => -0.53}).
			set_state(:open, {:hidden => false, :offset_x => -0.48, :offset_y => -0.47})

		@events_button.on_clicked {
			toggle_inputs_flyout!
		}

		# Project corner button (upper left)
		self << @project_menu_button = GuiButton.new.set(:scale_x => 0.04, :scale_y => 0.06, :offset_x => -0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png'))
		@project_menu_button.on_clicked {
			@overlay.switch_state({:closed => :open}, duration=0.4)
			@main_menu.switch_state({:closed => :open}, duration=0.2)
		}

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

		# Auto-select first director
		director = $engine.project.directors.first

		# Hack to load project file format 1
		director.actors = $engine.project.actors if director.actors.empty? and not $engine.project.actors.empty?

		self.chosen_actor = nil
		self.chosen_director = director
		self.mode = OUTPUT_MODE
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
		self.mode = DIRECTOR_MODE
	end

	#
	# Rendering: render is called every frame, gui_render! only when the Editor plugin thinks it's visible 
	#
	def render
		with_scale(0.75, 1.0) {		# TODO: properly set aspect ratio
			case @mode
			when ACTOR_MODE
				@actor_view.gui_render!
			when DIRECTOR_MODE
				@director_view.gui_render!
			when OUTPUT_MODE
				yield
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

	#
	# Main show / destroy API
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

	def trash!(user_object)
		@actors_flyout.remove(user_object)
		@actor_view.actor = nil if @actor_view.actor == user_object

		@directors_list.remove(user_object)
		@director_view.director = nil if @director_view.director == user_object

		@variables_flyout.remove(user_object)

		@history.remove(user_object)

		clear_editors! if @user_object_editors[user_object]
	end

	#
	# Click Response
	#
	def pointer_click_on_nothing(pointer)
		hide_something!
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
	# Keyboard interaction
	#

	# raw_keyboard_input is called by SDL
	def raw_keyboard_input(value)
		if @keyboard_grab_proc
			@keyboard_grab_proc.call(value)
		elsif @keyboard_grab_object
			@keyboard_grab_object.on_key_press(value)
		else
			@keypress_router.on_key_press(value)
		end
	end

	def grab_keyboard(object=nil, &proc)
		@keyboard_grab_object, @keyboard_grab_proc = object, proc
	end

	def cancel_keyboard_focus!
		@keyboard_grab_object, @keyboard_grab_proc = nil, nil
	end

	def has_keyboard_focus?(object)
		@keyboard_grab_object && object == @keyboard_grab_object
	end

	def cancel_keyboard_focus_for(object)
		cancel_keyboard_focus! if has_keyboard_focus?(object)
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
		end
	end

	def suitable_for_history?(object)
		[Actor, Variable, Event].any? { |klass| object.is_a? klass }
	end

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

	def toggle_beat_monitor!
		@beat_monitor.switch_state({:open => :closed, :closed => :open}, duration=0.2)
	end

	#
	# Next/Previous actor selection
	#
	def select_next_actor!
		return unless @actor_view.actor && @director_view.director && @director_view.director.actors.size > 0
		index = ((chosen_actor_index || -1) + 1) % @director_view.director.actors.size
		build_editor_for(@director_view.director.actors[index])
	end

	def select_previous_actor!
		return unless @actor_view.actor && @director_view.director && @director_view.director.actors.size > 0
		index = ((chosen_actor_index || 1) - 1) % @director_view.director.actors.size
		build_editor_for(@director_view.director.actors[index])
	end

	def chosen_actor_index
		@director_view.director.actors.index(@actor_view.actor)
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
