class EventInputSliderAbove < EventInput
	title				"Slider Above"
	description "Activates while slider is above chosen cutoff."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'cutoff', :float, :range => 0.0..1.0

	def value
		slider > cutoff
	end
end
