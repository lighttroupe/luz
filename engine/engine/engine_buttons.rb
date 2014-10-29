module EngineButtons
	include Callbacks

	callback :new_button

	def init_buttons
		@button_down = Hash.new
		@button_down_frame_number = Hash.new
		@button_up_frame_number = Hash.new
		@button_press_count = Hash.new
	end

	# Button (binary) Input
	def button_grab(&proc)
		@button_grab_proc = proc
	end

	def on_button_press(name, frame_offset = 0)
		return if $engine.frame_number <= 1		# HACK: this seems to prevent a segfault when we receive input immediately

		on_button_down(name, frame_offset)
		on_button_up(name, frame_offset)
	end

	# returns whether button was eaten by a grab
	def on_button_down(name, frame_offset = 0)
		return unless name		# don't allow nil
		return if $engine.frame_number <= 1		# HACK: this seems to prevent a segfault when we receive input immediately

		$env[:last_message_bus_activity_at] = $env[:frame_time]

		new_button_notify_if_needed(name)

		# Some input devices don't send "button up" events, so we force it here (NOTE: of course user can still only use the button-down moment)
		on_button_up(name, frame_offset-1) if @button_down[name]		# TODO: is the -1 here correct?

		@button_down[name] = true
		@button_down_frame_number[name] = @frame_number + frame_offset
		#@button_up_frame_number.delete(name)		# TODO: is this correct?

		# NOTE: press counts is useful for 'toggle' style inputs and selecting from lists
		@button_press_count[name] ||= 0
		@button_press_count[name] += 1

		# Send signal if GUI is listening for button presses
		if @button_grab_proc
			@button_grab_proc.call(name)
			@button_grab_proc = nil		# TODO: should we only remove handler if proc returns true/false ?
			true		# eaten
		else
			false		# not eaten
		end
	end

	def on_button_up(name, frame_offset=0)
		return unless @button_down[name]		# ignore calls when button is not down

		$env[:last_message_bus_activity_at] = $env[:frame_time]

		new_button_notify_if_needed(name)
		@button_up_frame_number[name] = @frame_number + frame_offset
		@button_down[name] = false
	end

	def button_down?(name)
		new_button_notify_if_needed(name)
		@button_down[name] || false  # NOTE: can be nil if unseen
	end

	def button_up?(name)
		!button_down?(name)
	end

	def button_press_count(name)
		new_button_notify_if_needed(name)
		@button_press_count[name] || 0
	end

	def button_pressed_this_frame?(name)
		new_button_notify_if_needed(name)
		@button_down_frame_number[name] == @frame_number
	end

	def button_released_this_frame?(name)
		new_button_notify_if_needed(name)
		@button_up_frame_number[name] == @frame_number
	end

	def new_button_notify_if_needed(name)
		return if @button_press_count[name] || name.nil?
		@button_press_count[name] = 0			# Otherwise we'll new_slider_notify endlessly...
		@seen_buttons_list = @button_press_count.keys.sort
		new_button_notify(name)						# this lets us notify (fill GUI lists) after loading a set from disk
	end

	def seen_buttons_list
		@seen_buttons_list || []
	end
end
