class GuiFloat < GuiObject
	def initialize(object, method, min, max)
		super()
		@object, @method, @min, @max = object, '@'+method.to_s, min, max
		@value_label = BitmapFont.new.set(:scale_x => 0.9, :scale_y => 0.65)
		@change_speed_multiplier = 4.0
		@format_string = "%+0.2f"
		draggable!
	end

	def get_value
		@object.instance_variable_get(@method).to_f
	end

	def set_value(value)
		value = @min if @min && value < @min
		value = @max if @max && value > @max
		@object.instance_variable_set(@method, value)
	end

	def update_drag(pointer)
		distance = pointer.drag_delta_x + pointer.drag_delta_y		# NOTE: cummulative, so up+right is fastest
		change_per_second = change_per_second_for_distance(distance)
		set_value(get_value + (change_per_second * $env[:frame_time_delta])) unless change_per_second == 0.0
	end

	COLOR = [0.1, 0.1, 1.0, 1.0]
	def gui_render!
		return if hidden?
		with_positioning {
			gui_render_background

			#with_color([rand,rand,rand,0.5]) { unit_square } 		# test fill
			@value_label.set_string(generate_string)

			with_color(COLOR) {
				@value_label.gui_render!
			}
		}
	end

	def generate_string
		sprintf(@format_string, get_value).sub('+',' ')
	end

#	def gui_tick!
#		super
#		handle_drag
#	end

	def change_per_second_for_distance(distance)		# distance is in screen space-- the mouse's playground!
		distance_abs = distance.abs
		progress = distance.clamp(-0.25, 0.25) / 0.25
		scaled_progress = ((progress ** 3) + 1.0) / 2.0
		min, max = -20.0, 20.0		# TODO: base these on @min/@max somehow
		scaled_progress.scale(min, max)
	end

	def step_amount
		return 1.0 unless @min
		return 0.01
	end

	def scroll_up!(pointer)
		set_value(get_value + step_amount)
	end

	def scroll_down!(pointer)
		set_value(get_value - step_amount)
	end
end
