# superclass for single-value setting widgets like GuiTheme

class GuiListValue < GuiObject		# TODO: rename! GuiListSelect ?
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
		create_popup_list(pointer)
	end

	def create_popup_list(pointer)
		box = GuiBox.new.set(:offset_x => pointer.x, :offset_y => pointer.y, :color => [1,1,0,1], :scale_x => 0.0, :scale_y => 0.0).animate({:scale_x => 0.1, :scale_y => 0.4}, duration=0.1)

		# Wrap the objects with a Renderer
		renderers = list.map { |item| GuiObjectRenderer.new(item) }
		renderers.each { |r|
			r.on_clicked {
				renderers.each { |r2| r2.hidden! unless r==r2 }		# FX: all but the selected item disappears
				set_value(r.object)
				box.exit!
			}
		}

		box << (popup=GuiListWithControls.new(renderers).set(:scroll_wrap => true, :spacing_y => -1.0, :item_aspect_ratio => 1.6))
		add_to_root(box)

		pointer.capture_object!(popup) { |click_object|
			if popup.has_widget_object?(click_object)
				true		# user is working with the popup... keep the capture
			else
				pointer.uncapture_object!
				box.exit!
				false
			end
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

