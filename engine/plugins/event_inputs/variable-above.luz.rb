class EventInputVariableAbove < EventInput
	title				"Variable Above"
	description ""

	categories :slider		# for now

	setting 'variable', :variable, :summary => true
	setting 'cutoff', :float, :range => 0.0..1.0

	def value
		(variable_setting.immediate_value > cutoff)
	end
end
