class GuiToggle < GuiObject
	callback :clicked
	easy_accessor :image

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

	def on?
		get_value
	end

	def click(pointer)
		set_value(!get_value)
		clicked_notify
	end

	def gui_render!
		with_gui_object_properties {
			with_scale(0.6, 0.4) {
				with_color(get_value ? COLOR_ON : COLOR_OFF) {
					image.using {
						unit_square
					}
				}
			}
		}
	end
end

