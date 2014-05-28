class VariableInputMinutesStepped < VariableInput
	title				"Minutes Stepped"
	description "The stepped progress of the minute hand of an analog clock showing the current Real-World time."

	categories :special

	def value
		Time.now.min / 60.0
	end
end
