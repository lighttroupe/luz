class VariableInputButtonPair < VariableInput
	title				"Button Pair"
	description "Activation rises when one button is pressed, lowers when a different button is pressed, and stays steady when neither (or both) are pressed."

	categories :button

	setting 'button_on', :button, :summary => '% on'
	setting :on_time, :timespan
	setting 'button_off', :button, :summary => '% off'
	setting :off_time, :timespan

	setting 'starting_value', :float, :simple => true, :range => 0.0..1.0, :default => 0.0..1.0

	def value
		return starting_value if first_frame?

		on = $engine.button_down?(button_on)
		off = $engine.button_down?(button_off)

		if on && off
			last_value
		elsif on
			return 1.0 if on_time.instant?
			last_value + ($env[:frame_time_delta] / on_time.to_seconds)
		elsif off
			return 0.0 if off_time.instant?
			last_value - ($env[:frame_time_delta] / off_time.to_seconds)
		else
			last_value
		end
	end
end
