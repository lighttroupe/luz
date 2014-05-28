class ProjectEffectBeatResetTo1 < ProjectEffect
	title				'Beat Reset To 1'
	description 'Resets the beat number to 1.'

	setting 'event', :event, :summary => true

	def tick
		$engine.next_beat_is_zero! if event.now?
	end
end
