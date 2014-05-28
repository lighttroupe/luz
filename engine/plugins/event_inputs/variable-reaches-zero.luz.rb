class EventInputVariableReachesZero < EventInput
	title				"Variable Reaches Zero"
	description ""

	categories :slider		# for now

	setting 'variable', :variable, :summary => true

	def value
		(variable_setting.last_value > 0.0) && (variable_setting.immediate_value == 0)
	end
end
