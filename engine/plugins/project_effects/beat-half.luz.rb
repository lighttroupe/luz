class ProjectEffectBeatHalf < ProjectEffect
	title				"Beat Half"
	description "Half-times beat on next opportunity."

	setting 'event', :event, :summary => true

	def tick
		$engine.beat_half_time! if event.now?
	end
end
