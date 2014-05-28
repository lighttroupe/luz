class VariableInputSlider < VariableInput
	title				"Slider"
	description "Reads value from a slider."

	categories :slider

	hint "Supports MIDI sliders and knobs, MIDI piano keys and drum pads, Mice, Wacom Tablets, Touchpads, Joysticks, and OpenSoundControl messages (with a single float parameter in the range 0.0 to 1.0)."

	setting :slider, :slider, :summary => true

	def value
		slider
	end
end
