class VariableInputSliderMultiplier < VariableInput
	title				"Slider Multiplier"
	description "Combines two sliders with multiplication."

	categories :slider

	setting 'slider_one', :slider, :summary => true
	setting 'slider_two', :slider, :summary => true

	def value
		slider_one * slider_two
	end
end
