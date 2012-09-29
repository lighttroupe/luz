# superclass for single-value setting widgets like GuiTheme

class GuiListValue < GuiObject
	easy_accessor :no_value_text

	def initialize(object, method)
		super()
		@object, @method = object, '@'+method.to_s
		@no_value_text = 'none'
	end

	def get_value
		@object.instance_variable_get(@method)
	end

	def set_value(value)
		@object.instance_variable_set(@method, value)
	end

	def gui_render!
		with_gui_object_properties {
			if (object = get_value)
				object.gui_render!
			else
				gui_render_no_value
			end
		}
	end

	def gui_render_no_value
		@no_value_label ||= BitmapFont.new.set(:string => @no_value_text, :scale => 0.75, :opacity => 0.1)
		@no_value_label.gui_render!
	end

	def click(pointer)
		scroll_down!(pointer)
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

