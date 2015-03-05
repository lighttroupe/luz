class GuiMessageBar < GuiBox
	MESSAGE_DURATION = 2.0
	MESSAGE_DURATION_FAST = 1.0

	def initialize
		super
		self << (@background = GuiObject.new.set(:background_image => $engine.load_image('images/message-bar-background.png')))
		self << (@text = GuiLabel.new.set(:width => 20, :text_align => :center))
	end

	def messages
		@messages ||= []
	end

	def positive_message(message)
		messages << message
	end
	alias :negative_message :positive_message		# for now

	def gui_tick
		super
		next_message! if next_message?
	end

	def desired_duration
		(messages.size > 0) ? MESSAGE_DURATION_FAST : MESSAGE_DURATION
	end

	def current_duration
		(@message_time.nil?) ? 0.0 : $env[:frame_time] - @message_time
	end

	def next_message?
		(@message_time.nil? && !messages.empty?) ||		# introduce a message?
		(current_duration > desired_duration)		# move to next message?
	end

	def next_message!
		message = messages.shift
		if message
			@text.set_string(message).set({:hidden => false})
			animate(:opacity, 1.0, duration=0.01)
			@message_time = $env[:frame_time]
		else
			animate(:opacity, 0.0, duration=0.2) { }
			@message_time = nil
		end
	end
end
