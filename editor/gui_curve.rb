class GuiCurve < GuiObject
	def initialize(object, method)
		super()
		@object, @method = object, '@'+method.to_s
	end

	def get_value
		@object.instance_variable_get(@method)
	end

	def set_value(value)
		@object.instance_variable_set(@method, value)
	end

	def current_index
		index = $engine.project.curves.index(get_value)
	end

	def gui_render!
		return if hidden?
		return unless (curve = get_value)
		with_positioning {
			curve.gui_render!
		}
	end

	def click(pointer)
	end

	def scroll_up!(pointer)
		index = (current_index - 1) % $engine.project.curves.size
		set_value $engine.project.curves[index]
	end

	def scroll_down!(pointer)
		index = (current_index + 1) % $engine.project.curves.size
		set_value $engine.project.curves[index]
	end
end
