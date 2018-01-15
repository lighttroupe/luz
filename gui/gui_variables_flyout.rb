#
# GuiVariablesFlyout is the left-edge window containing variables and events lists.
#
class GuiVariablesFlyout < GuiWindow
	def initialize
		super
		create!
	end

	def create!
		# Background
		self << (@background = GuiObject.new.set(:background_image => $engine.load_image('images/variables-flyout-background.png')))

		# Events list
		self << @events_list = GuiList.new.set(:scale_x => 0.85, :scale_y => 0.37, :offset_x => -0.06, :offset_y => 0.22, :item_aspect_ratio => 3.0, :spacing_y => -1.0)
		@events_list.contents = $engine.project.events.map { |event| create_renderer_for_event(event) }
		@events_list.on_contents_change { $engine.project.events = @events_list.map(&:object) ; $engine.project_changed! }
		@gui_events_list_scrollbar = GuiScrollbar.new(@events_list).set(:scale_x => 0.08, :scale_y => 0.37, :offset_x => 0.4, :offset_y => 0.22)
		self << @gui_events_list_scrollbar

		# New Event button
		self << (@new_event_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.045, :offset_x => 0.0, :offset_y => -0.013, :background_image => $engine.load_image('images/buttons/new-event-button.png'), :background_image_hover => $engine.load_image('images/buttons/new-event-button-hover.png')))
		@new_event_button.on_clicked { |pointer| new_event! }

		#
		# Variables
		#
		self << @variables_list = GuiList.new($engine.project.variables.map(&:new_renderer)).set(:scale_x => 0.85, :scale_y => 0.37, :offset_x => -0.06, :offset_y => -0.24, :item_aspect_ratio => 3.0, :spacing_y => -1.0)
		@variables_list.contents = $engine.project.variables.map { |variable| create_renderer_for_variable(variable) }
		@variables_list.on_contents_change { $engine.project.variables = @variables_list.map(&:object) ; $engine.project_changed! }
		@gui_variables_list_scrollbar = GuiScrollbar.new(@variables_list).set(:scale_x => 0.08, :scale_y => 0.37, :offset_x => 0.4, :offset_y => -0.24)
		self << @gui_variables_list_scrollbar

		# New Variable button
		self << (@new_variable_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.043, :offset_x => 0.0, :offset_y => -0.476, :background_image => $engine.load_image('images/buttons/new-variable-button.png'), :background_image_hover => $engine.load_image('images/buttons/new-variable-button-hover.png')))
		@new_variable_button.on_clicked { |pointer| new_variable!(pointer) }
	end

	def remove(obj)
		@variables_list.remove(obj)
		@events_list.remove(obj)
	end

	def new_variable!(pointer=nil)
		variable = Variable.new
		renderer = create_renderer_for_variable(variable)
		@variables_list.add_after_selection(renderer)
		@variables_list.set_selection(renderer)
		$gui.build_editor_for(variable, :pointer => pointer)
		$gui.user_object_editor_edit_text
		$engine.project.variables = @variables_list.map(&:object)
		$engine.project_changed!
		variable
	end

	def create_renderer_for_variable(variable)
		renderer = variable.new_renderer
		renderer.on_clicked { |pointer| $gui.build_editor_for(variable, :pointer => pointer, :grab_keyboard_focus => true) }
		renderer.on_double_clicked { |pointer| $gui.user_object_editor_edit_text }
		renderer
	end

	def new_event!(pointer=nil)
		event = Event.new
		renderer = create_renderer_for_event(event)
		@events_list.add_after_selection(renderer)
		@events_list.set_selection(renderer)
		$gui.build_editor_for(event, :pointer => pointer)
		$gui.user_object_editor_edit_text
		#$engine.project.events = @events_list.map(&:object)
		$engine.project_changed!
		event
	end

	def create_renderer_for_event(event)
		renderer = event.new_renderer
		renderer.on_clicked { |pointer| $gui.build_editor_for(event, :pointer => pointer, :grab_keyboard_focus => true) }
		renderer.on_double_clicked { |pointer| $gui.user_object_editor_edit_text }
		renderer
	end

	def on_key_press(key)
		if key.control?
			case key
			when 'n'
				if key.control?
					if @events_list.keyboard_focus?
						new_event!
					elsif @variables_list.keyboard_focus?
						new_variable!
					end
				end
			when 'd'
				if key.control?
					$gui.negative_message "duplicate not implemented"

					#if @events_list.keyboard_focus?
						#if (selected = @events_list.selection.first)
							#original = selected.object
							#duplicate = original.deep_clone_user_object
							#renderer = create_renderer_for_event(duplicate)
							#@events_list.add_after_selection(renderer)
							#@events_list.set_selection(renderer)
						#end
					#elsif @variables_list.keyboard_focus?
						#if (selected = @variables_list.selection.first)
							#original = selected.object
							#duplicate = original.deep_clone_user_object
							#renderer = create_renderer_for_variable(duplicate)
							#@variables_list.add_after_selection(renderer)
							#@variables_list.set_selection(renderer)
						#end
					#end
				end
			else
				super
			end
		else
			case key
			when 'up'
				@events_list.grab_keyboard_focus!
			when 'down'
				@variables_list.grab_keyboard_focus!
			when 'left'
				self.grab_keyboard_focus!
			when 'right'
				if @events_list.keyboard_focus?
					@variables_list.grab_keyboard_focus!
				elsif @variables_list.keyboard_focus?
					@events_list.grab_keyboard_focus!
				elsif self.keyboard_focus?
					@events_list.grab_keyboard_focus!
				end
			when 'return'
				if @events_list.keyboard_focus?
					renderer = @events_list.selection.first
					$gui.build_editor_for(renderer.object, :grab_keyboard_focus => true) if renderer
				elsif @variables_list.keyboard_focus?
					renderer = @variables_list.selection.first
					$gui.build_editor_for(renderer.object, :grab_keyboard_focus => true) if renderer
				end
			else
				super
			end
		end
	end
end
