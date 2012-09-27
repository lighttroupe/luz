require 'gui_numeric'

class GuiFloat < GuiNumeric
	def initialize(object, method, min, max)
		super(object, method, min, max)
		@change_speed_multiplier = 4.0
		@format_string = "%+0.2f"
		@zero_value = 0.0
		draggable!
	end

	def get_value
		super.to_f
	end

	def update_drag(pointer)
		distance = pointer.drag_delta_x + pointer.drag_delta_y		# NOTE: cummulative, so up+right is fastest
		change_per_second = change_per_second_for_distance(distance)
		set_value(get_value + (change_per_second * $env[:frame_time_delta])) unless change_per_second == 0.0
	end

	def purify_value(value)
		sprintf(@format_string, value).to_f
	end

	def end_drag(pointer)
		set_value(purify_value(get_value))
	end

	def change_per_second_for_distance(distance)		# distance is in screen space-- the mouse's playground!
		distance_abs = distance.abs
		progress = distance.clamp(-0.25, 0.25) / 0.25
		scaled_progress = ((progress ** 3) + 1.0) / 2.0
		min, max = -20.0, 20.0		# TODO: base these on @min/@max somehow
		scaled_progress.scale(min, max)
	end

	def step_amount
		if @step_amount
			@step_amount
			# enough to step up to next value
			#(get_value + @step_amount) - (get_value + @step_amount) % @step_amount
		elsif @min && @max
			# calculate a good value based on min/max
			range = (@max - @min)
			if range > 8
				value_abs = get_value.abs
				if value_abs >= 1000.0
					100.0
				elsif value_abs >= 100.0
					10.0
				elsif value_abs >= 1
					1.0
				else
					0.1
				end
			else
				0.1
			end
		else
			1.0
		end
	end
end
