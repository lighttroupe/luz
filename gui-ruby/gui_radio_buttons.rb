class GuiRadioButton < GuiObject
	ON_COLOR = [1,1,1,1]
	OFF_COLOR = [0.0,0.0,0.0,0.5]

	easy_accessor :parent
	easy_accessor :value

	def gui_render!
		with_color(on? ? ON_COLOR : OFF_COLOR) {
			unit_square
		}
	end

	def click(pointer)
		parent.set_value(value)
	end

	def on?
		parent.get_value == value
	end
end

class GuiRadioButtons < GuiList
	def initialize(object, method, options)
		super()
		@object, @method, @options = object, method.to_s, options
		@options.each { |value|
			self << GuiRadioButton.new.set_value(value).set_parent(self)
		}
	end

	def get_value
		@object.send(@method)
	end

	def set_value(value)
		@object.send("#{@method}=", value)
		selection_change_notify
	end

	def selected_index
		@options.index(get_value)
	end

	def set_index(index)
		set_value(@options[(index) % @options.size])
	end

	def click(pointer)
		set_index(selected_index + 1) if selected_index
	end
end
