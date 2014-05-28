class EventInputAlways < EventInput
	title				"Always"
	description "Always activated."

	categories :special

	def value
		true
	end
end
