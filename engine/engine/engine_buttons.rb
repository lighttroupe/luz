module EngineButtons
	include Callbacks

	attr_reader :seen_buttons_list

	def init_buttons
		@button_down = Hash.new(false)
		@button_down_frame_number = Hash.new
		@button_up_frame_number = Hash.new
		@button_press_count = Hash.new(0)
		@seen_buttons_list = []
	end

	#
	# button press/release response
	#
	# returns whether button was eaten by a grab
	def on_button_down(name, frame_offset = 0)
		return false unless name
		on_new_button(name)

		# Some input devices don't send "button up" events, so we force it here (NOTE: of course user can still only use the button-down moment)
		on_button_up(name, frame_offset-1) if @button_down[name]		# TODO: is the -1 here correct?

		@button_down[name] = true
		@button_down_frame_number[name] = @frame_number + frame_offset

		# NOTE: press counts is useful for 'toggle' style inputs and selecting from lists
		#@button_press_count[name] ||= 0
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

		$env[:last_message_bus_activity_at] = $env[:frame_time]		# TODO: move elsewhere?

		on_new_button(name)
		@button_up_frame_number[name] = @frame_number + frame_offset
		@button_down[name] = false
	end

	# Button (binary) Input
	def button_grab(&proc)
		@button_grab_proc = proc
	end

	#
	# button status API
	#
	def button_down?(name)
		return false unless name
		on_new_button(name)
		@button_down[name]		# || false  # NOTE: can be nil if unseen
	end

	def button_press_count(name)
		return 0 unless name
		on_new_button(name)
		@button_press_count[name]
	end

	def button_pressed_this_frame?(name)
		return false unless name
		on_new_button(name)
		@button_down_frame_number[name] == @frame_number
	end

	def button_released_this_frame?(name)
		return false unless name
		on_new_button(name)
		@button_up_frame_number[name] == @frame_number
	end

private

	def on_new_button(name)
		return if @seen_buttons_list.include?(name)
		raise ArgumentError unless name
		@seen_buttons_list << name
		@seen_buttons_list.sort!
	end
end
