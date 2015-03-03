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

		#self << @message_bus_monitor = GuiMessageBusMonitor.new.set(:scale_x => 0.91, :scale_y => 0.060, :offset_x => 0.0, :offset_y => 0.5 - 0.065/2.0, :background_image => $engine.load_image('images/message-bus-monitor-background.png'))

		# Events list				TODO: don't use $engine here
		self << @events_list = GuiList.new($engine.project.events).set(:scale_x => 0.85, :scale_y => 0.37, :offset_x => -0.06, :offset_y => 0.22, :item_aspect_ratio => 3.0, :spacing_y => -1.0)

		# ...scrollbar
		@gui_events_list_scrollbar = GuiScrollbar.new(@events_list).set(:scale_x => 0.08, :scale_y => 0.37, :offset_x => 0.4, :offset_y => 0.22)
		self << @gui_events_list_scrollbar

		# New Event button
		self << (@new_event_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.045, :offset_x => 0.0, :offset_y => -0.013, :background_image => $engine.load_image('images/buttons/new-event-button.png'), :background_image_hover => $engine.load_image('images/buttons/new-event-button-hover.png')))
		@new_event_button.on_clicked { |pointer|
			new_event!
		}

		# Variables list		TODO: don't use $engine here
		self << @variables_list = GuiList.new($engine.project.variables).set(:scale_x => 0.85, :scale_y => 0.37, :offset_x => -0.06, :offset_y => -0.24, :item_aspect_ratio => 3.0, :spacing_y => -1.0)

		# ...scrollbar
		@gui_variables_list_scrollbar = GuiScrollbar.new(@variables_list).set(:scale_x => 0.08, :scale_y => 0.37, :offset_x => 0.4, :offset_y => -0.24)
		self << @gui_variables_list_scrollbar

		# New Variable button
		self << (@new_variable_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.043, :offset_x => 0.0, :offset_y => -0.476, :background_image => $engine.load_image('images/buttons/new-variable-button.png'), :background_image_hover => $engine.load_image('images/buttons/new-variable-button-hover.png')))
		@new_variable_button.on_clicked { |pointer|
			new_variable!(pointer)
		}
	end

	def variables=(variables)
		#@variables_list.contents = variables
	end

	def events=(events)
		#@events_list.contents = events
	end

	def remove(obj)
		@variables_list.remove(obj)
		@events_list.remove(obj)
	end

	def new_variable!(pointer=nil)
		variable = Variable.new
		@variables_list.add_after_selection(variable)
		@variables_list.set_selection(variable)
		$gui.build_editor_for(variable, :pointer => pointer)
		$engine.project_changed!
		variable
	end

	def new_event!(pointer=nil)
		event = Event.new
		@events_list.add_after_selection(event)
		@events_list.set_selection(event)
		$gui.build_editor_for(event, :pointer => pointer)
		$engine.project_changed!
		event
	end

	def on_key_press(key)
		if key.control?
			case key
			when 'n'
				if key.control?
					if @events_list.keyboard_focus?
						new_event!
						#close!
					elsif @variables_list.keyboard_focus?
						new_variable!
						#close!
					end
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
					$gui.build_editor_for(@events_list.selection.first)
				elsif @variables_list.keyboard_focus?
					$gui.build_editor_for(@variables_list.selection.first)
				end
			else
				super
			end
		end
	end
end
