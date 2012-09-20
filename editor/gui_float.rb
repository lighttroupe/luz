class GuiFloat < GuiObject
	def initialize(object, method, min, max)
		super()
		@object, @method, @min, @max = object, '@'+method.to_s, min, max
		@value_label = BitmapFont.new.set(:scale_x => 0.95, :scale_y => 0.7)
		@change_speed_multiplier = 4.0
		@format_string = "%+0.2f"
	end

	def get_value
		@object.instance_variable_get(@method).to_f
	end

	def set_value(value)
		value = @min if @min && value < @min
		value = @max if @max && value > @max
		@object.instance_variable_set(@method, value)
	end

	def gui_render!
		with_positioning {
			render_selection if pointer_hovering?
			with_color([rand,rand,rand,0.5]) { unit_square } 		# test fill
			@value_label.set_string(sprintf(@format_string, get_value))
			@value_label.gui_render!
		}
	end

	def click(pointer)
		return if @pointer
		@pointer = pointer
		@pointer_starting_x = @pointer.x
		@pointer_starting_y = @pointer.y
	end

	def gui_tick!
		super
		return unless @pointer
		if @pointer.hold?
			distance = (@pointer.x - @pointer_starting_x) + (@pointer.y - @pointer_starting_y)
			change_per_second = change_per_second_for_distance(distance)

			set_value(get_value + (change_per_second * $env[:frame_time_delta])) unless change_per_second == 0.0
		else
			@pointer = nil
		end
	end

	def change_per_second_for_distance(distance)		# distance is in screen space-- the mouse's playground!
		distance_abs = distance.abs
		#return 0.0 if distance_abs < 0.02		# no change within a small box
		progress = distance.clamp(-0.25, 0.25) / 0.25
		scaled_progress = ((progress ** 3) + 1.0) / 2.0
#puts scaled_progress
		min, max = -20.0, 20.0
		v = scaled_progress.scale(min, max)
		#v = (distance.scale(1.0, 5.0) ** 3)
#		v += (v > 0) ? -1.0 : 1.0
		#puts "#{distance} => #{v}"
		v
	end

	SELECTION_COLOR = [1.0,1.0,1.0,0.25]
	def render_selection
		with_color(SELECTION_COLOR) {
			unit_square
		}
	end
end
