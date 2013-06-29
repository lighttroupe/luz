multi_require 'gui_list_select'
multi_require 'gui_engine_slider_renderer'

class GuiEngineSlider < GuiListSelect
	VALUE_COLOR = [0.0, 0.0, 0.4, 0.8]

	def initialize(object, method)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@selected_label = BitmapFont.new.set(:string => get_value, :scale_x => 0.9, :scale_y => 0.65)
		@item_aspect_ratio = 6.0
	end

	def list
		$engine.seen_sliders_list.map { |slider| GuiEngineSliderRenderer.new(slider) }
	end

	def set_value(value)
		super(value.text)
		@selected_label.set_string(get_value)
	end

	def gui_render!
		with_gui_object_properties {
			if (v=$engine.slider_value(get_value)) > 0.0
				with_translation(-0.5 + v/2.0, 0.0) {
					with_scale_unsafe(v, 1.0) {
						with_color(VALUE_COLOR) {
							unit_square
						}
					}
				}
			end
			@selected_label.gui_render!
		}
	end

	def step_amount
		1
	end
end
