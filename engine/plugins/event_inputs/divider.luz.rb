class EventInputDivider < EventInput
	title				"- - - - - - - -"
	description "Hey, nice divider!"

	categories :special

	hint "Useful as a spacer in your event inputs list."

	def value
		false
	end
end
