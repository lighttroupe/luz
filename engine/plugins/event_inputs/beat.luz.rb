class EventInputBeat < EventInput
	title				"Beat"
	description "Activates once on the beat."

	categories :special

	def value
		$env[:is_beat]
	end
end
