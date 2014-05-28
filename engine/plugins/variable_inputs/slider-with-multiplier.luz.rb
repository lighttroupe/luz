class VariableInputSliderWithMultiplier < VariableInput
	title				"Slider with Multiplier"
	description "Multiplies slider value with a manual control."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'scaler', :float, :range => 0..1.0, :default => 1.0..1.0

	def value
		slider * scaler
	end
end
