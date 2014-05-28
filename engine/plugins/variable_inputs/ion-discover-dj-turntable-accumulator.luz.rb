class VariableInputIonDiscoverDJTurntableAccumulator < VariableInput
	title				"Ion Discover DJ Turntable Accumulator"
	description "Uses the rotational speed of turntables to increase or decrease activation."

	categories :device

	hint 'This plugin is written to handle the unique data patterns sent by a specific device, and may not be useful for other purposes.'

	setting 'slider', :slider, :summary => true
	setting 'modulator', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def value
		if slider < 0.5
			last_value + modulator * (slider / 0.2).clamp(0.0, 1.0)
		else
			last_value - modulator * ((1.0 - slider) / 0.2).clamp(0.0, 1.0)
		end
	end
end
