class EventInputButtonPair < EventInput
	title				"Button Pair"
	description "Activation turns on with one button press, turns off with a different button press."

	categories :button

	setting 'button_on', :button, :summary => true
	setting 'button_off', :button, :summary => true

	def value
		if $engine.button_pressed_this_frame?(button_on)
			true
		elsif $engine.button_pressed_this_frame?(button_off)
			false
		else
			last_value
		end
	end
end
