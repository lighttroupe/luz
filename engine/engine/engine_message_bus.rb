module EngineMessageBus
	def init_message_bus
		@message_buses = []
	end

	def add_message_bus(ip, port)
		message_bus = MessageBus.new.listen(ip, port)
		message_bus.on_button_down(&method(:on_button_down))
		message_bus.on_button_up(&method(:on_button_up))
		message_bus.on_slider_change(&method(:on_slider_change))
		@message_buses << message_bus
	end

	def read_from_message_bus
		@message_buses.each(&:update)
	end
end
