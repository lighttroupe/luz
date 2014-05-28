class EventInputButtonRelease < EventInput
	title				"Button Release"
	description "Activates once when button (PC Keyboard, MIDI, OpenSoundControl) is released."

	categories :button

	setting 'button', :button, :summary => true

	def value
		$engine.button_released_this_frame?(button)
	end
end
