class GuiNumeric < GuiObject
	def initialize(object, method, min, max)
		super()
		@object, @method, @min, @max = object, '@'+method.to_s, min, max
		@value_label = BitmapFont.new.set(:offset_y => -0.12, :scale_x => 0.9, :scale_y => 0.65)
		@color = [0.1, 0.1, 1.0, 1.0]
	end

	def get_value
		@object.instance_variable_get(@method)
	end

	def set_value(value)
		value = @min if @min && value < @min
		value = @max if @max && value > @max
		@object.instance_variable_set(@method, value)
	end

	def gui_render!
		with_gui_object_properties {
			@value_label.set_string(generate_string)
			@value_label.gui_render!
		}
	end

	def generate_string
		sprintf(@format_string, get_value).sub('+',' ')
	end

	#
	# Mouse Interaction
	#
	def scroll_up!(pointer)
		set_value(get_value + step_amount)
	end

	def scroll_down!(pointer)
		set_value(get_value - step_amount)
	end
end
