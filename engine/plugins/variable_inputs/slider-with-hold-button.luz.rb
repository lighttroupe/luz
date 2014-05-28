class VariableInputSliderWithHoldButton < VariableInput
	title				"Slider with Hold Button"
	description "Holds slider value while button is pressed, otherwise acts as normal."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'button', :button, :summary => true

	def value
		if $engine.button_down?(button)
			last_value
		else
			slider
		end
	end
end
