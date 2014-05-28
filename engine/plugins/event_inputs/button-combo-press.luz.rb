class EventInputButtonComboPress < EventInput
	title				"Button Combo Press"
	description "Activates once when two buttons are pressed at the same time."

	categories :button

	setting 'button_one', :button, :summary => true
	setting 'button_two', :button, :summary => true

	def value
		$engine.button_pressed_this_frame?(button_one) && $engine.button_pressed_this_frame?(button_two)
	end
end
