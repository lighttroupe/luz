# superclass for single-value setting widgets like GuiTheme

class GuiListValue < GuiObject
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

	def gui_render!
		return unless (object = get_value)
		with_gui_object_properties {
			object.gui_render!
		}
	end

	def scroll_up!(pointer)
		list_cached = list
		current_index = list_cached.index(get_value)
		next_index = current_index ? ((current_index - 1) % list_cached.size) : 0
		set_value list_cached[next_index]
	end

	def scroll_down!(pointer)
		list_cached = list
		current_index = list_cached.index(get_value)
		next_index = current_index ? ((current_index + 1) % list_cached.size) : 0
		set_value list_cached[next_index]
	end
end

