class VariableInputHours < VariableInput
	title				"Hours"
	description "The smooth progress of the hour hand of an analog clock showing the current Real-World time."

	categories :special

	def value
		time = Time.now
		(time.hour + (time.min + ((time.sec + (time.usec / 1000000.0)) / 3600.0)) / 60.0) / 24.0
	end
end
