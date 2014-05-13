module EngineMessageBus
	def read_from_message_bus
		@message_buses.each { |bus| bus.update }
	end
end
