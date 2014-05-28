class VariableInputRandomizeOnEvent < VariableInput
	title				"Randomize on Event"
	description "Provides a new random activation level with each event."

	categories :special

	setting 'event', :event, :summary => true

	def value
		if event.now?
			rand
		else
			last_value
		end
	end
end
