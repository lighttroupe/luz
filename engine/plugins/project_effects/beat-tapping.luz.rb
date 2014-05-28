class ProjectEffectBeatTapping < ProjectEffect
	title				'Beat Tapping'
	description 'Teach Luz about the beat of the playing music.'

	setting 'event', :event, :summary => true

	def tick
		$engine.beat! if event.now?
	end
end
