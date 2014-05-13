module EngineSliders
	include Callbacks

	callback :new_slider

	def init_sliders
		@slider_values = Hash.new
		@slider_delayed_updates = Hash.new
		@slider_values_last_update_frame = Hash.new
	end

	def slider_tick
		@slider_delayed_updates.each_pair { |k, v| on_slider_change(k, v, delayed=true) }
		@slider_delayed_updates.clear
	end

	#
	# Sliders (also knobs, and any other 0.0 -> 1.0 inputs)
	#
	def slider_grab(&proc)
		@slider_grab_proc = proc
	end

	def cancel_slider_grab
		@slider_grab_proc = nil
	end

	def on_slider_change(name, value, delayed=false)
		return if $engine.frame_number <= 1		# HACK: this seems to prevent a segfault when we receive input immediately

		$env[:last_message_bus_activity_at] = $env[:frame_time]

		new_slider_notify_if_needed(name)

		# special-case one type of change:
		# - 2+ slider changes in one frame
		# - second value goes to 0.0
		# this prevents a quick "a=1,a=0" from being immediately overridden
		frame_number = $env[:frame_number]
		if (delayed == false) and (@slider_values_last_update_frame[name] == frame_number) and (value == 0.0)
			@slider_delayed_updates[name] = value
		else
			@slider_values[name] = value
			@slider_values_last_update_frame[name] = frame_number
		end

		# Send signal if GUI is listening (for auto-mapping inputs via Record button)
		if @slider_grab_proc
			@slider_grab_proc = nil if @slider_grab_proc.call(name)		# true = eaten
		end
	end

	def slider_value(name)
		new_slider_notify_if_needed(name)
		v = @slider_values[name]
		unless v
			@slider_values[name] = v = 0.0		# Otherwise we'll new_slider_notify endlessly...
			new_slider_notify(name)		# this lets us notify (fill GUI lists) after loading a set from disk
		end
		return v
	end

	def new_slider_notify_if_needed(name)
		return if @slider_values[name]
		@slider_values[name] = 0.0				# Otherwise we'll new_slider_notify endlessly...
		@seen_sliders_list = @slider_values.keys.delete_if { |key, value| key.nil? }.sort		# TODO: fix need for this nil check!?
		new_slider_notify(name)						# this lets us notify (fill GUI lists) after loading a set from disk
	end

	def seen_sliders_list
		@seen_sliders_list || []
	end
end
