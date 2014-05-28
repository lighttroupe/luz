class EventInputButtonToggle < EventInput
	title				"Button Toggle"
	description "Activates every frame after first button press, turns off after second press."

	categories :button

	setting 'button', :button, :summary => true
	setting 'clear', :button, :summary => true

	def value
		if $engine.button_pressed_this_frame?(clear)
			false
		elsif $engine.button_pressed_this_frame?(button)
			!last_value
		else
			last_value
		end
	end
end
