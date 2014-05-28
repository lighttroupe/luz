class EventInputButtonSeen < EventInput
	title				"Button Seen"
	description "Activates once when button is first pressed, and stays activated for the rest of the performance."

	categories :button

	hint				"This can be useful for enabling optional project features, like a second drawing tablet."

	setting 'button', :button, :summary => true

	def value
		last_value || $engine.button_pressed_this_frame?(button)
	end
end
