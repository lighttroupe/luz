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

		# Events list				TODO: don't use $engine here
		self << @events_list = GuiList.new($engine.project.events).set(:scale_x => 0.91, :scale_y => 0.37, :offset_x => -0.036, :offset_y => 0.22, :item_aspect_ratio => 3.2, :spacing_y => -1.0)

		# New Event button
		self << (@new_event_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.045, :offset_x => 0.0, :offset_y => -0.013, :background_image => $engine.load_image('images/buttons/new-event-button.png')))
		@new_event_button.on_clicked { |pointer|
			@events_list.add_after_selection(event = Event.new)
			$gui.build_editor_for(event, :pointer => pointer)
		}

		# Variables list		TODO: don't use $engine here
		self << @variables_list = GuiList.new($engine.project.variables).set(:scale_x => 0.91, :scale_y => 0.37, :offset_x => -0.036, :offset_y => -0.24, :item_aspect_ratio => 3.2, :spacing_y => -1.0)

		# New Variable button
		self << (@new_variable_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.043, :offset_x => 0.0, :offset_y => -0.476, :background_image => $engine.load_image('images/buttons/new-variable-button.png')))
		@new_variable_button.on_clicked { |pointer|
			@variables_list.add_after_selection(variable = Variable.new)
			$gui.build_editor_for(variable, :pointer => pointer)
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

	def on_key_press(key)
		case key
		when 'up'
			@variables_list.grab_keyboard_focus!
		when 'down'
			@events_list.grab_keyboard_focus!
		when 'return'
			if @events_list.keyboard_focus?
				$gui.build_editor_for(@events_list.selection.first)
			elsif @variables_list.keyboard_focus?
				$gui.build_editor_for(@variables_list.selection.first)
			end
		end
		super
	end
end
