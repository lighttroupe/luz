class VariableInputSliderWithSilencerButton < VariableInput
	title				"Slider with Silencer Button"
	description "Reads value from slider, but reports 0% activation while button is pressed."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'button', :button, :summary => true

	def value
		if $engine.button_down?(button)
			0.0
		else
			slider
		end
	end
end
