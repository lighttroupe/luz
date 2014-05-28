class EventInputBeatOffset < EventInput
	title				"Beat Offset"
	description "Activates once per beat, at a chosen offset into the beat."

	categories :special

	setting 'offset', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def value
		if $env[:previous_beat_scale] < offset
			# passed the offset point or passed it and looped
			($env[:beat_scale] >= offset) || $env[:is_beat]
		else
			($env[:beat_scale] >= offset) && $env[:is_beat]
		end
	end
end

