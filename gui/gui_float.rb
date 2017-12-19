multi_require 'gui_numeric'

class GuiFloat < GuiNumeric
	def initialize(object, method, min, max, digits)
		super(object, method, min, max)
		@change_speed_multiplier = 4.0
		@format_string = "%+0.#{digits}f"
		@zero_value = 0.0
		draggable!
	end

	#
	# API
	#
	def get_value
		super.to_f
	end

	#
	# Callbacks
	#
	def update_drag(pointer)
		distance = pointer.drag_delta_x + pointer.drag_delta_y		# NOTE: cummulative, so up+right is fastest
		change_per_second = change_per_second_for_distance(distance)
		set_value(get_value + (change_per_second * $env[:frame_time_delta])) unless change_per_second == 0.0
	end

	def end_drag(pointer)
		set_value(purify_value(get_value))
	end

	#
	# Helpers
	#

private

	def change_per_second_for_distance(distance)		# distance is in screen space-- the mouse's playground!
		distance_abs = distance.abs
		progress = distance.clamp(-0.25, 0.25) / 0.25
		scaled_progress = ((progress ** 3) + 1.0) / 2.0
		min, max = -20.0, 20.0		# TODO: base these on @min/@max somehow
		scaled_progress.scale(min, max)
	end

	def purify_value(value)
		sprintf(@format_string, value).to_f
	end

	def calculate_step_value(direction)		# :up or :down
		# Feature: fixed step amount
		if @step_amount
			(get_value + ((direction==:up) ? @step_amount : -@step_amount))			# TODO: enough to step up to next value (get_value + @step_amount) - (get_value + @step_amount) % @step_amount
		else
			get_value + smart_step_value(get_value, direction)
		end
	end

	# This chooses how much to "step" when using scroll wheel or buttons to go up/down in value
	def smart_step_value(value, direction)
		swapped = false
		swapped, value, direction = true, value.abs, ((direction == :up) ? :down : :up) if value < 0.0
		# Now we can pretend we're in the positive range going up or down

		# TODO: this implementation seems overly complex for such a pattern-rich job
		step = if direction == :up
			if value >= 1000.0 ; 1000.0 ; elsif value >= 100.0 ; 100.0 ; elsif value >= 10.0; 10.0 ; elsif value >= 1.0 ; 1.0 ; elsif value >= 0.1 ; 0.1 ; else ; 0.01 ; end
		else
			if value <= 0.1 ; -0.01 ; elsif value <= 1.0 ; -0.1 ; elsif value <= 10.0 ; -1.0 ; elsif value <= 100.0 ; -10.0 ; elsif value <= 1000.0 ; -100.0 ; else ; -1000.0 ; end
		end

		# Finally, transform back
		value, step = -value, -step if swapped
		step
	end
end
