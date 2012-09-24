require 'gui_list_value'

class GuiSelect < GuiListValue
	def initialize(object, method, options)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@options = options
		@list = @options.map { |o| o.first }
		@selected_label = BitmapFont.new.set(:string => selected_label_text, :scale_x => 0.9, :scale_y => 0.65)
	end

	def selected_label_text
		value = get_value
		@options.find { |o| o.first == value }.last
	end

	def set_value(value)
		super(value)
		@selected_label.set_string(selected_label_text)
	end

	def gui_render!
		with_positioning {
			@selected_label.gui_render!
		}
	end

	def click(pointer)
		scroll_down!(pointer)
	end

	def step_amount
		1
	end

	def list
		@list
	end
end
