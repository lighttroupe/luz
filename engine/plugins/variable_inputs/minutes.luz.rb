class VariableInputMinutes < VariableInput
	title				"Minutes"
	description "The smooth progress of the minute hand of an analog clock showing the current Real-World time."

	categories :special

	def value
		time = Time.now
		(time.min + (time.sec + (time.usec / 1000000.0)) / 3600.0) / 60.0
	end
end
