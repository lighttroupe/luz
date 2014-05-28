class VariableInputSecondsStepped < VariableInput
	title				"Seconds Stepped"
	description "The stepped progress of the seconds hand of an analog clock showing the current Real-World time."

	categories :special

	def value
		Time.now.sec / 60.0
	end
end
