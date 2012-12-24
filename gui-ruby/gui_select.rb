require 'gui_list_select'

#
# This is a non-popup list
#
class GuiSelect < GuiListSelect
	def initialize(object, method, options)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@options = options
		@list = @options.map { |o| o.first }
		@selected_label = BitmapFont.new.set(:string => selected_label_text, :scale_x => 0.9, :scale_y => 0.65, :offset_y => -0.12)
		@color = [0.6, 0.6, 1.0, 1.0]
	end

	#
	# API
	#
	def set_value(value)
		super(value)
		@selected_label.set_string(selected_label_text)
	end

	def list
		@list
	end

	#
	# Rendering
	#
	def gui_render!
		with_gui_object_properties {
			@selected_label.gui_render!
		}
	end

	#
	# Pointer
	#
	def click(pointer)
		scroll_down!(pointer)
	end

	#
	# Settings
	#
	def step_amount
		1
	end

private

	def selected_label_text
		value = get_value
		@options.find { |o| o.first == value }.last
	end
end
