require 'osc_server'
require 'callbacks'

class MessageBus < OSCServer
	include Callbacks

	# button/slider value changes
	callback :button_down
	callback :button_up
	callback :slider_change

private

	def on_new_message(address, value)
		if value.is_a? Float
			slider_change_notify(address, (value > 1.0) ? 1.0 : ((value < 0.0) ? 0.0 : value))
		elsif value.is_a? Integer
			if value >= 1
				button_down_notify(address)
			else
				button_up_notify(address)
			end
		else
			@ignored_message_count += 1
		end
	end
end
