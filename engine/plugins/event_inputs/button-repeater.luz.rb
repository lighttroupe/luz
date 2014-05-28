class EventInputButtonRepeater < EventInput
	title				"Button Repeater"
	description "Activates on press, then at a set interval until released."

	categories :button

	setting 'button', :button, :summary => true
	setting 'period', :timespan, :summary => true

	def value
		$engine.button_pressed_this_frame?(button) || ($engine.button_down?(button) && (time_since_last_activation > period.to_seconds))
	end
end
