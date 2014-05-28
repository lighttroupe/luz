class VariableInputSliderTripple < VariableInput
	title				"Slider Tripple"
	description "Combines three sliders with multiplication."

	categories :slider

	setting 'slider_one', :slider, :summary => true
	setting 'slider_two', :slider, :summary => true
	setting 'slider_three', :slider, :summary => true

	def value
		slider_one * slider_two * slider_three
	end
end
