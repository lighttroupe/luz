class VariableInputSliderWithActivatorButton < VariableInput
	title				"Slider with Activator Button"
	description "Reads value from slider while button is pressed, otherwise reports previous value."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'button', :button, :summary => true

	def value
		if $engine.button_down?(button)
			slider
		else
			last_value
		end
	end
end
