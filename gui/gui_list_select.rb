# superclass for single-value setting widgets like GuiTheme
multi_require 'gui_list_popup'

class GuiListSelect < GuiObject
	easy_accessor :no_value_text, :item_aspect_ratio

	def initialize(object, method)
		super()
		@object, @method = object, '@'+method.to_s
		@no_value_text = 'none'
		@item_aspect_ratio = 1.6
	end

	#
	# API
	#
	def get_value
		@object.instance_variable_get(@method)
	end

	def set_value(value)
		@object.instance_variable_set(@method, value)
	end

	#
	# Render
	#
	def gui_render!
		with_gui_object_properties {
			object = get_value
			if object
				object.gui_render!
			else
				gui_render_no_value
			end
		}
	end

	def gui_render_no_value
		@no_value_label ||= GuiLabel.new.set(:width => :fill, :string => @no_value_text, :scale => 0.75, :opacity => 0.1)
		@no_value_label.gui_render!
	end

	#
	# Mouse interaction
	#
	def click(pointer)
		create_popup_list(pointer)
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

private

	def create_popup_list(pointer)
		# Wrap the objects with a Renderer
		renderers = list	#.map { |item| GuiObjectRenderer.new(item) }

		popup = GuiListPopup.new(pointer).set(:offset_x => pointer.x, :offset_y => pointer.y, :scale_x => 0.0, :scale_y => 0.0, :item_aspect_ratio => item_aspect_ratio).
			set_objects(renderers).
			animate({:scale_x => 0.2, :scale_y => 0.6}, duration=0.15)

		popup.on_selected { |object|
			set_value(object)
			#popup.exit!
		}

		add_to_root(popup)
	end
end

