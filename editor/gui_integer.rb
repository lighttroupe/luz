require 'gui_numeric'

class GuiInteger < GuiNumeric
	def initialize(object, method, min, max)
		super(object, method, min, max)
		@change_speed_multiplier = 4.0
		@format_string = "%+d"
		@zero_value = 0
		draggable!
	end

	def get_value
		super.to_i
	end

	def update_drag(pointer)
		distance = pointer.drag_delta_x + pointer.drag_delta_y		# NOTE: cummulative, so up+right is fastest
		change = change_for_distance(distance)
		change *= -1 if distance < 0.0
		set_value(get_value + change) unless change == 0
	end

	# NOTE: always returns positive amount
	def change_for_distance(distance)		# distance is in screen space-- the mouse's playground!
		@gui_previous_count ||= 0

		distance_abs = distance.abs
		count, remainder = $env[:beat].divmod(0.5)
		delta = (count - @gui_previous_count)

		@gui_previous_count = count		# save for next time

		if distance_abs > 0.2
			delta > 0 ? 4 : 0
		elsif distance_abs > 0.1
			delta > 0 ? 2 : 0
		elsif distance_abs > 0.01
			($env[:is_beat]) ? 1 : 0
		else
			0
		end
	end

	def step_amount
		1
	end
end
