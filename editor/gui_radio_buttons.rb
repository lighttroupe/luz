class GuiRadioButton < GuiObject
	ON_COLOR = [1,1,1,1]
	OFF_COLOR = [0.0,0.0,0.0,0.5]

	easy_accessor :parent
	easy_accessor :value

	def on?
		parent.get_value == value
	end

	def gui_render!
		is_on = on?
		with_color(is_on ? ON_COLOR : OFF_COLOR) {
			unit_square
		}
	end

	def click(pointer)
		parent.set_value(value)
	end
end

class GuiRadioButtons < GuiList
	def initialize(object, method, options)
		super()
		@object, @method, @options = object, '@'+method.to_s, options
		@options.each { |value|
			self << GuiRadioButton.new.set_value(value).set_parent(self)
		}
	end

	def get_value
		@object.instance_variable_get(@method)
	end

	def set_value(value)
		@object.instance_variable_set(@method, value)
	end

	def click(pointer)
		index = @options.index(get_value)
		set_value(@options[(index + 1) % @options.size])
	end
end
