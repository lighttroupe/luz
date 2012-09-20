class GuiToggle < GuiObject
	COLOR_ON = [0.7,1,0.7,1]
	COLOR_OFF = [1.0,0.7,0.7,0.5]
	def initialize(object, method)
		super()
		@object, @method = object, '@'+method.to_s
	end
	def get_value
		@object.instance_variable_get(@method) == true
	end

	def set_value(value)
		@object.instance_variable_set(@method, value)
	end

	def click(pointer)
		set_value(!get_value)
	end

	def gui_render!
		with_positioning {
			with_color(get_value ? COLOR_ON : COLOR_OFF) {
				unit_square
			}
		}
	end
end

