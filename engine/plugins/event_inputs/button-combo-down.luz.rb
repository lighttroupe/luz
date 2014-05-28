class EventInputButtonComboDown < EventInput
	title				"Button Combo Down"
	description "Activates when two buttons are pressed at the same time."

	categories :button

	setting 'button_one', :button, :summary => true
	setting 'button_two', :button, :summary => true

	def value
		$engine.button_down?(button_one) && $engine.button_down?(button_two)
	end
end
