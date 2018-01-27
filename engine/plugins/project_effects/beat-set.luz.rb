class ProjectEffectBeatSet < ProjectEffect
	title				"Beat Set"
	description ""

	setting 'event_up', :event, :summary => true
	setting 'event_down', :event, :summary => true

	def tick
		if event_up.now?
			if event_down.now?
			else
				$engine.beats_per_minute = ($engine.beats_per_minute + 1)
			end
		elsif event_down.now?
			$engine.beats_per_minute = [($engine.beats_per_minute - 1), 1].max
		end
	end
end
