class VariableInputManual < VariableInput
	title				"Manual"
	description "Set activation level manually."

	categories :special

	setting 'activation', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def value
		activation
	end
end
