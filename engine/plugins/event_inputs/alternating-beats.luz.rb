class EventInputAlternatingBeats < EventInput
	title				"Alternating Beats"
	description "Activates during one beat, off for the next."

	categories :special

	def value
		$env[:beat_number] % 2 == 0
	end
end
