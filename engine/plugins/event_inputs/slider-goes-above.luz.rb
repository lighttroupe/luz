class EventInputSliderGoesAbove < EventInput
	title				"Slider Goes Above"
	description "Activates when slider goes from below to above a chosen cutoff."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'cutoff', :float, :range => 0.0..1.0

	def value
		(slider_setting.last_value <= cutoff and slider > cutoff)
	end
end
