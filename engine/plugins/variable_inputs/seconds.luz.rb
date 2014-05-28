class VariableInputSeconds < VariableInput
	title				"Seconds"
	description "The smooth progress of the seconds hand of an analog clock showing the current Real-World time."

	categories :special

	def value
		time = Time.now
		(time.sec + (time.usec / 1000000.0)) / 60.0
	end
end
