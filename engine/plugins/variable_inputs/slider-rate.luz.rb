class VariableInputSliderRate < VariableInput
	title				"Slider Rate"
	description "Slider values over chosen pivot point grows the activation, values under the pivot point shrinks activation."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'pivot_point', :float, :range => 0.001..0.999, :default => 0.5..0.999
	setting 'fill_time', :timespan, :summary => true

	def value
		if slider > pivot_point
			(last_value + (($env[:frame_time_delta] / fill_time.to_seconds) * ((slider - pivot_point) / pivot_point)))
		else
			(last_value - (($env[:frame_time_delta] / fill_time.to_seconds) * ((pivot_point - slider) / (1.0 - pivot_point))))
		end
	end
end
