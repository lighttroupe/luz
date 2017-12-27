#
# GuiTimeControl lets user control speed of engine time
#
class GuiTimeControl < GuiObject
	def initialize
		draggable!
		super
	end

	def update_drag(pointer)
		distance = pointer.drag_delta_x
		set_value(1.0 + distance * 1000.0)

		#change = change_for_distance(distance)
		#change *= -1 if distance < 0.0
		#set_value(get_value + change) unless change == 0
	end

	def end_drag(pointer)
		set_value(1.0)
	end

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

	def set_value(v)
		$engine.simulation_speed = v
	end

	def get_value
		$engine.simulation_speed
	end
end
