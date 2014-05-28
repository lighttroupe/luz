class EventInputSliderSegmentedUp < EventInput
	title				"Slider Segmented Up"
	description "Activates each time slider crosses a boundary of one of a chosen number of segments going up."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'count', :integer, :range => 1..10000, :summary => '% segments'

	def value
		old_i = (count + 1).choose_index_by_fuzzy(slider_setting.last_value)
		new_i = (count + 1).choose_index_by_fuzzy(slider)
		delta = (new_i - old_i)

		(delta > 0) ? delta : 0
	end
end
