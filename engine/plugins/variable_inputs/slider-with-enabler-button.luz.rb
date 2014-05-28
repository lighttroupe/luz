class VariableInputSliderWithEnablerButton < VariableInput
	title				"Slider with Enabler Button"
	description "Reads value from chosen slider while chosen button is pressed, otherwise reports a chosen default value."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'button', :button, :summary => true
	setting 'default_value', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def value
		if $engine.button_down?(button)
			slider
		else
			default_value
		end
	end
end
