#
# Sliders (also knobs, and any other 0.0 -> 1.0 inputs)
#
module EngineSliders
	include Callbacks

	callback :new_slider

	attr_reader :seen_sliders_list

	def init_sliders
		@slider_values = Hash.new(0.0)
		@slider_delayed_updates = Hash.new
		@slider_values_last_update_frame = Hash.new
		@seen_sliders_list = []
	end

	def slider_tick
		@slider_delayed_updates.each_pair { |k, v| on_slider_change(k, v, delayed=true) }
		@slider_delayed_updates.clear
	end

	def slider_grab(&proc)
		@slider_grab_proc = proc
	end
	def cancel_slider_grab
		@slider_grab_proc = nil
	end

	def on_slider_change(name, value, delayed=false)
		return unless name
		on_new_slider(name)

		# special-case one type of change:
		# - 2+ slider changes in one frame
		# - second value goes to 0.0
		# this prevents a quick "a=1,a=0" from being lost
		frame_number = $env[:frame_number]
		if (delayed == false) && (@slider_values_last_update_frame[name] == frame_number) && (value == 0.0)
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
		return 0.0 unless name
		on_new_slider(name)
		@slider_values[name]
	end

private

	def on_new_slider(name)
		return if @seen_sliders_list.include?(name)
		raise ArgumentError unless name
		@seen_sliders_list << name
		@seen_sliders_list.sort!
	end
end
