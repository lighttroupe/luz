class VariableInputSliderSeekUpDown < VariableInput
	title				"Slider Seek Up Down"
	description "Output value moves towards the input value, at different speeds while moving up and down."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'seek_time_up', :timespan, :summary => '% up'
	setting 'seek_time_down', :timespan, :summary => '% down'

	def value
		from = last_value
		to = slider

		if from != to
			time = (to > from) ? seek_time_up.to_seconds : seek_time_down.to_seconds
			(from + (($env[:time_delta] / time).clamp(0.0, 1.0) * (to - from)))
		else
			to
		end
	end
end
