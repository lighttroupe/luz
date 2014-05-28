class VariableInputTime < VariableInput
	title				"Time"
	description "Fills once from 0% to 100% over a chosen time period."

	categories :special

	hint "Useful as the progress for music videos."

	setting 'time', :timespan, :summary => true

	def value
		time.progress_since(0.0)
	end
end
