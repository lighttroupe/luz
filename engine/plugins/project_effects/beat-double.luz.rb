class ProjectEffectBeatDouble < ProjectEffect
	title				"Beat Double"
	description "Double-times beat on next opportunity."

	setting 'event', :event, :summary => true

	def tick
		$engine.beat_double_time! if event.now?
	end
end
