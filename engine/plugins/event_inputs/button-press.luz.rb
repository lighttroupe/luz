class EventInputButtonPress < EventInput
	title				"Button Press"
	description "Activates once when button is pressed."

	categories :button

	setting 'button', :button, :summary => true

	def value
		$engine.button_pressed_this_frame?(button)
	end
end
