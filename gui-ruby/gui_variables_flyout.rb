class GuiVariablessFlyout < GuiBox
	def initialize
		super
		create!
	end

	def create!
		# Background
		self << (@background = GuiObject.new.set(:background_image => $engine.load_image('images/variables-flyout-background.png')))

		# New Event button
		self << (@new_event_button = GuiButton.new.set(:scale_x => 0.45, :scale_y => 0.05, :offset_x => -0.25, :offset_y => -0.45, :background_image => $engine.load_image('images/buttons/new.png')))
		@new_event_button.on_clicked { |pointer|
			@events_list.add_after_selection(event = Event.new)
			$gui.build_editor_for(event, :pointer => pointer)
		}

		# New Variable button
		self << (@new_variable_button = GuiButton.new.set(:scale_x => 0.45, :scale_y => 0.05, :offset_x => 0.25, :offset_y => -0.45, :background_image => $engine.load_image('images/buttons/new.png')))
		@new_variable_button.on_clicked { |pointer|
			@variables_list.add_after_selection(variable = Variable.new)
			$gui.build_editor_for(variable, :pointer => pointer)
		}

		# Events list				TODO: don't use $engine here
		self << @events_list = GuiList.new($engine.project.events).set(:scale_x => 1.0, :scale_y => 0.45, :offset_y => 0.22, :item_aspect_ratio => 3.2, :spacing_y => -1.0)

		# Variables list		TODO: don't use $engine here
		self << @variables_list = GuiList.new($engine.project.variables).set(:scale_x => 1.0, :scale_y => 0.45, :offset_y => -0.23, :item_aspect_ratio => 3.2, :spacing_y => -1.0)
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
end
