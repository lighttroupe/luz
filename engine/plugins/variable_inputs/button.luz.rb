class VariableInputButton < VariableInput
	title				"Button"
	description "Activation rises while button is pressed, lowers while button is not pressed."

	categories :button

	hint "All 'Button' type input plugins support keyboard keys, mouse buttons, Wiimote buttons, MIDI device buttons, and OpenSoundControl messages with a single integer parameter (0 or 1)."

	setting 'button', :button, :summary => true
	setting 'on_time', :timespan, :summary => '% on'
	setting 'off_time', :timespan, :summary => '% off'

	def value
		if $engine.button_down?(button)
			return 1.0 if on_time.instant?
			last_value + ($env[:frame_time_delta] / on_time.to_seconds)
		else
			return 0.0 if off_time.instant?
			last_value - ($env[:frame_time_delta] / off_time.to_seconds)
		end
	end
end
