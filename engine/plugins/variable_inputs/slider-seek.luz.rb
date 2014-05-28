class VariableInputSliderSeek < VariableInput
	title				"Slider Seek"
	description "Output value moves towards the input value at a chosen speed."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'seek_time', :timespan, :summary => true

	def value
		from = last_value
		to = slider
		if from != to
			(from + (($env[:time_delta] / seek_time.to_seconds).clamp(0.0, 1.0) * (to - from)))
		else
			to
		end
	end
end
