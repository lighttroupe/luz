class EventInputButtonDown < EventInput
	title				"Button Down"
	description "Activates every frame while button is pressed."

	categories :button

	setting 'button', :button, :summary => true

	def value
		$engine.button_down?(button)
	end
end
