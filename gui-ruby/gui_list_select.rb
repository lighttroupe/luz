# superclass for single-value setting widgets like GuiTheme

class GuiListSelect < GuiObject
	easy_accessor :no_value_text

	def initialize(object, method)
		super()
		@object, @method = object, '@'+method.to_s
		@no_value_text = 'none'
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
			set_value(list.first) unless (object = get_value)
			if object
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

		box << (popup=GuiListWithControls.new(renderers).set(:scroll_wrap => true, :spacing_y => -1.0, :item_aspect_ratio => 1.6)).scroll_to(self.get_value)
		add_to_root(box)

		# Pointer takes responsibility for this window, and it auto-closes when pointer clicks away
		pointer.capture_object!(popup) { |click_object|		# callback is for a click
			if click_object.is_a?(GuiObject) && popup.includes_gui_object?(click_object)
				true		# user is working with the popup... keep the capture
			else
				pointer.uncapture_object!
				box.exit!
				false
			end
		}
	end
end

