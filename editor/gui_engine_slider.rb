require 'gui_list_value'

class GuiEngineSlider < GuiListValue
	def initialize(object, method)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@selected_label = BitmapFont.new.set(:string => get_value, :scale_x => 0.9, :scale_y => 0.65)
	end

	def list
		$engine.seen_sliders_list
	end

	def set_value(value)
		super(value)
		@selected_label.set_string(get_value)
	end

	def gui_render!
		with_positioning {
			@selected_label.gui_render!
		}
	end

	def step_amount
		1
	end
end
