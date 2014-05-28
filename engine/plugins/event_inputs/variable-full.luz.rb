class EventInputVariableFull < EventInput
	title				"Variable Full"
	description ""

	categories :slider		# for now

	setting 'variable', :variable, :summary => true

	def value
		(variable_setting.immediate_value == 1.0)
	end
end
