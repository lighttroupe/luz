class VariableInputIonDiscoverDJTurntable < VariableInput
	title				"Ion Discover DJ Turntable"
	description "Reports rotational speed of turntable in a variety of ways."

	categories :device

	hint 'This plugin is written to handle the unique data patterns sent by a specific device, and may not be useful for other purposes.'

	setting('slider', :slider, {:summary => true})
	setting 'mode', :select, :options => [[:bidirectional, 'Bidirectional'], [:forward, 'Forward'], [:backward, 'Backward']], :default => :bidirectional

	def value
		case mode
		when :bidirectional
			if slider < 0.5
				0.5 + (slider / 0.2).clamp(0.0, 1.0) / 2.0
			else
				0.5 - ((1.0 - slider) / 0.2).clamp(0.0, 1.0) / 2.0
			end
		when :forward
			if slider < 0.5
				(slider / 0.2)
			else
				0.0
			end
		when :backward
			if slider < 0.5
				0.0
			else
				((1.0 - slider) / 0.2)
			end
		else
			raise NotImplementedError
		end
	end
end
