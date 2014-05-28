class VariableInputButtonToggle < VariableInput
	title				"Button Toggle"
	description "Activation begins rising when button is pressed once, lowers when button is pressed a second time."

	categories :button

	setting 'button', :button, :summary => true
	setting 'on_time', :timespan, :summary => '% on'
	setting 'off_time', :timespan, :summary => '% off'

	def value
		if $engine.button_press_count(button).is_odd?
			return 1.0 if on_time.instant? or last_value.nil?
			return (last_value + ($env[:frame_time_delta] / on_time.to_seconds)).clamp(0.0, 1.0)
		else
			return 0.0 if off_time.instant? or last_value.nil?
			return (last_value - ($env[:frame_time_delta] / off_time.to_seconds)).clamp(0.0, 1.0)
		end
	end
end
