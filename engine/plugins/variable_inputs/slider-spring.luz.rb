class VariableInputSliderSpring < VariableInput
	title				"Slider Spring"
	description "Acts as if a spring of a chosen strength is pulling the current value to the chosen slider value."

	categories :slider

	setting :slider, :slider, :summary => true

	setting :spring_strength, :float, :range => 0.0..2.0, :default => 0.1..1.0
	setting :spring_damper, :float, :range => 0.0..1.0, :default => 0.9..1.0

	def value
		delta = (slider - last_value)

		# Accelerate
		@velocity = (((@velocity || 0.0) * spring_damper) + (delta * spring_strength))

		last_value + @velocity
	end
end
