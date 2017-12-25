# superclass for single-value setting widgets like GuiTheme
multi_require 'gui_list_popup'

class GuiListSelect < GuiValue
	easy_accessor :no_value_text, :item_aspect_ratio, :width

	def initialize(object, method)
		super
		@no_value_text = 'none'
		@item_aspect_ratio = 1.6
	end

	#
	# Render
	#
	def gui_render
		with_gui_object_properties {
			object = get_value
			if object
				@current_value_renderer = object.new_renderer if @current_value_renderer.nil? || @current_value_renderer.object != object
				@current_value_renderer.gui_render		# TODO: renderer not attached, better to attach at time of selection than this
			else
				gui_render_no_value
			end
		}
	end

	def gui_render_no_value
		@no_value_label ||= GuiLabel.new.set(:width => 6, :text_align => :center, :string => @no_value_text, :scale => 0.75, :opacity => 0.1)
		@no_value_label.gui_render
	end

	#
	# Mouse interaction
	#
	def click(pointer)
		if list.empty?
			$gui.positive_message "None! Create One"
		else
			create_popup_list(pointer)
		end
	end

	def scroll_up!(pointer)
		list_cached = list
		current_index = list_cached.index(get_value)
		next_index = current_index ? ((current_index - 1) % list_cached.size) : 0
		set_value(list_cached[next_index])
	end

	def scroll_down!(pointer)
		list_cached = list
		current_index = list_cached.index(get_value)
		next_index = current_index ? ((current_index + 1) % list_cached.size) : 0
		set_value(list_cached[next_index])
	end

private

	def create_popup_list(pointer)
		# Wrap the objects with a Renderer
		renderers = list

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

