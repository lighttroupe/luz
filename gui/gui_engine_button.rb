multi_require 'gui_list_select', 'gui_engine_button_renderer'

class GuiEngineButton < GuiListSelect
	def initialize(object, method)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@selected_label = BitmapFont.new.set(:string => get_value, :scale_x => 0.9, :scale_y => 0.65)
		@item_aspect_ratio = 5.0
	end

	def list
		$engine.seen_buttons_list.map { |slider| GuiEngineButtonRenderer.new(slider) }
	end

	def set_value(value)
		super(value.to_s)
		@selected_label.set_string(get_value)
	end

	VALUE_COLOR = [0.0, 0.0, 0.4, 0.8]
	def gui_render!
		with_gui_object_properties {
			if $engine.button_down?(get_value)
				with_color(VALUE_COLOR) {
					unit_square
				}
			end
			@selected_label.gui_render!
		}
	end

	def step_amount
		1
	end
end
