multi_require 'gui_list_select'

#
# This is a non-popup list
#
class GuiSelect < GuiListSelect
	def initialize(object, method, options)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@options = options
		@list = @options.map(&:first)		# keys
		@selected_label = GuiLabel.new.set(:width => 10, :string => selected_label_text, :scale_x => 0.9)
		@color = [0.6, 0.6, 1.0, 1.0]
	end

	pipe [:width=, :text_align=], :selected_label

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
	def gui_render
		with_gui_object_properties {
			@selected_label.gui_render
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

	def find_option_string_by_value(value)
		v = @options.find { |o| o.first == value }
		v.last if v		# otherwise nil (last is the string part)
	end

	def selected_label_text
		find_option_string_by_value(get_value) || ''
	end
end
