class GuiMessageBar < GuiBox
	MESSAGE_DURATION = 1.5

	def initialize
		super
		self << (@text = BitmapFont.new)
	end


	def messages
		@messages ||= []
	end

	def positive_message(message)
		messages << message
	end

	def gui_tick!
		super
		next_message! if next_message?
	end

	def next_message?
		(@message_time.nil? && !messages.empty?) || (!@message_time.nil? && ($env[:frame_time] - @message_time) > MESSAGE_DURATION)
	end

	def next_message!
		message = messages.shift
		if message
			@text.set_string(message).animate(:opacity, 1.0, duration=0.01)
			@message_time = $env[:frame_time]
		else
			@text.animate(:opacity, 0.0, duration=0.2)
			@message_time = nil
		end
	end
end
