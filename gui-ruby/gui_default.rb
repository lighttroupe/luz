multi_require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_hbox', 'gui_vbox', 'gui_list', 'gui_scrollbar', 'gui_list_with_controls', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider', 'gui_radio_buttons', 'gui_object_renderer', 'gui-ruby/fonts/bitmap-font', 'gui_main_menu', 'gui_window'
load_directory(Dir.pwd + '/gui-ruby/addons/', '**.rb')		# Addons to existing objects
multi_require 'gui_actor_view', 'gui_director_view', 'gui_preferences_box', 'gui_user_object_editor', 'gui_add_window', 'gui_interface', 'gui_actor_class_button', 'gui_director_menu', 'gui_actors_flyout', 'gui_variables_flyout', 'keyboard'

class GuiDefault < GuiInterface
	pipe [:positive_message, :negative_message], :message_bar

	attr_accessor :mode, :directors_menu

	def initialize
		super
		create!
		add_state(:closed, {:scale_x => 1.5, :scale_y => 1.5, :opacity => 0.0, :hidden => true})
		set_state(:open, {:scale_x => 1.0, :scale_y => 1.0, :opacity => 1.0, :hidden => false})
	end

	def toggle!
		switch_state({:open => :closed, :closed => :open}, duration=0.35)
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

		@actor_view = GuiActorView.new	#.set(:opacity => 0.0, :hidden => true)
		@director_view = GuiDirectorView.new	#.set(:opacity => 0.0, :hidden => true)

		#
		# Actors / Directors flyout
		#
		self << @actors_flyout = GuiActorsFlyout.new.set(:scale_x => 0.12, :scale_y => 1.0, :offset_x => 0.5 - 0.06).
			add_state(:open, {:offset_x => 0.44, :hidden => false}).
			set_state(:closed, {:offset_x => 0.56, :hidden => true})

		# Directors corner button (top right)
		self << (@directors_button = GuiButton.new.set(:scale_x => -0.04, :scale_y => 0.06, :offset_x => 0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png')))
		@directors_button.on_clicked {
			open_directors_menu!
		}

		# Actors corner button (bottom right)
		self << (@actors_button = GuiButton.new.set(:scale_x => -0.04, :scale_y => -0.06, :offset_x => 0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png')))
		@actors_button.on_clicked {
			toggle_actors_flyout!
		}

		#
		# Events / Variables flyout
		#
		self << @variables_flyout = GuiVariablesFlyout.new.set(:scale_x => 0.12, :scale_y => 1.0, :offset_x => -0.44).
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
		self << @directors_menu = GuiDirectorMenu.new($engine.project.directors).
			add_state(:open, {:scale_x => 1.0, :scale_y => 1.0, :opacity => 1.0, :hidden => false}).
			set_state(:closed, {:scale_x => 1.1, :scale_y => 1.1, :offset_y => 0.0,:hidden => true})

		# Message Bar
		self << (@message_bar = GuiMessageBar.new.set(:offset_x => 0.02, :offset_y => 0.5 - 0.05, :scale_x => 0.32, :scale_y => 0.05))

		# Beat Monitor
		self << @beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:scale_x => 0.10, :scale_y => 0.02, :background_scale_x => 1.2, :background_scale_y => 1.2, :background_image => $engine.load_image('images/drawer-n.png')).
			add_state(:closed, {:offset_x => 0.0, :offset_y => 0.55, :hidden => true}).
			set_state(:open, {:offset_x => 0.0, :offset_y => 0.49, :hidden => false})

		self << @directors_list = GuiListWithControls.new([]).set(:hidden => true)

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
		clear_editors!
	end

	#
	# Rendering: render is called every frame, gui_render! only when the Editor plugin thinks it's visible 
	#
	def render
		with_scale(0.62, 1.0) {		# TODO: properly set aspect ratio
			case @mode
			when :actor
				@actor_view.gui_render!
			when :director
				@director_view.gui_render!
			when :output
				yield
			end
		}

		gui_render!
	end

	#
	# build_editor_for is the main "object activated" message
	#
	def build_editor_for(user_object, options={})
		return unless user_object

		pointer = options[:pointer]
		editor = @user_object_editors[user_object]
		editor_visible = (editor && !editor.hidden?)

		if user_object.is_a?(Director)
			close_directors_menu! if self.chosen_director == user_object

			self.chosen_director = user_object

			return nil

		elsif user_object.is_a?(ParentUserObject) || user_object.is_a?(Project)		# TODO: responds_to? :effects ?
			case user_object
			when Actor
				if editor_visible
					@actor_view.actor = user_object
					self.mode = :actor
					return
				else
					# Rule: cannot edit one actor while viewing a different one (so show this actor while editing)
					@actor_view.actor = user_object if self.mode == :actor
				end
			when Variable, Event
				clear_editors! and return if editor_visible
			end

			#
			# Select / show object
			#
			clear_editors!		# only support one for now

			editor = create_user_object_editor_for_pointer(user_object, pointer || Vector3.new(0.0,-0.5), options)
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

	def trash!(user_object)
		@actors_flyout.remove(user_object)
		@actor_view.actor = nil if @actor_view.actor == user_object

		@directors_list.remove(user_object)
		@director_view.director = nil if @director_view.director == user_object

		@variables_flyout.remove(user_object)

		clear_editors! if @user_object_editors[user_object]
	end

	#
	# Utility methods
	#
	def create_user_object_editor_for_pointer(user_object, pointer, options)
		GuiUserObjectEditor.new(user_object, {:scale_x => 0.3, :scale_y => 0.05}.merge(options)).
			set({:offset_x => pointer.x + (0.0 - pointer.x) * 0.95, :offset_y => -0.25, :opacity => 0.0, :scale_x => 0.65, :scale_y => 0.5, :hidden => false}).
			animate({:offset_x => 0.0, :offset_y => -0.25, :scale_x => 0.65, :scale_y => 0.5, :opacity => 1.0}, duration=0.3)
	end

	def clear_editors!
		@user_object_editors.each { |user_object, editor|
			editor.animate({:opacity => 0.0, :offset_y => editor.offset_y - 0.05}, duration=0.1) {
				editor.remove_from_parent!		# trashed forever! (no cache)
			}
		}
		@user_object_editors.clear
	end

	def hide_something!
		if @directors_menu.visible?
			close_directors_menu!
			default_focus!
		elsif @variables_flyout.visible? or @actors_flyout.visible?
			close_inputs_flyout!
			close_actors_flyout!
			default_focus!
		end
	end

	def close_actors_flyout!
		@actors_flyout.switch_state({:open => :closed}, duration=0.2)
	end

	def open_directors_menu!
		@directors_menu.switch_state({:closed => :open},durection=0.4)
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

	#
	# Next/Previous actor selection
	#
	def select_next_actor!
		return unless chosen_director && chosen_director.actors.size > 0
		index = ((chosen_actor_index || -1) + 1) % chosen_director.actors.size
		build_editor_for(chosen_director.actors[index])
	end

	def select_previous_actor!
		return unless chosen_director && chosen_director.actors.size > 0
		index = ((chosen_actor_index || 1) - 1) % chosen_director.actors.size
		build_editor_for(chosen_director.actors[index])
	end

	def chosen_actor_index
		chosen_director.actors.index(chosen_actor)		# possibly nil
	end

	def default_focus!
		user_object_editor = @user_object_editor_container.first

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
				if @directors_menu.open?
					@directors_menu.close!
					default_focus!
				else
					@directors_menu.open!
					@directors_menu.grab_keyboard_focus!
				end
			when 'down'
				hide_something!
			when 'b'
				toggle_beat_monitor!
			when 'r'
				$engine.reload
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
			when 'up'
				select_previous_actor!
			end

		#
		# no modifier
		#
		else
			case key
			when 'escape'
				if @directors_menu.visible?
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
