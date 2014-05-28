class EventInputSliderReaches100 < EventInput
	title				"Slider Reaches 100%"
	description "Activates on the frame that the slider reaches 100%."

	categories :slider

	setting 'slider', :slider, :summary => true

	def value
		slider == 1.0 and slider_setting.last_value < 1.0
	end
end
