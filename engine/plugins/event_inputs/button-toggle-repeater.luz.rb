class EventInputButtonToggleRepeater < EventInput
	title				"Button Toggle Repeater"
	description "When toggled on, repeats periodically."

	categories :button

	setting 'button', :button, :summary => true
	setting 'period', :timespan, :summary => true

	def value
		@on = false if @on.nil?
		@on = !@on if $engine.button_pressed_this_frame?(button)
		@on && (time_since_last_activation > period.to_seconds)
	end
end
