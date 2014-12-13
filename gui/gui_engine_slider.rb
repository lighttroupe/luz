multi_require 'gui_list_select'
multi_require 'gui_engine_slider_renderer'

class GuiEngineSlider < GuiListSelect
	VALUE_COLOR = [0.2, 0.5, 0.2, 1.0]

	def initialize(object, method)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@selected_label = GuiLabel.new.set(:width => 17, :string => get_value, :scale_x => 0.9, :scale_y => 0.65)
		@item_aspect_ratio = 5.0
	end

	def list
		$engine.seen_sliders_list.map { |slider| GuiEngineSliderRenderer.new(slider) }
	end

	def set_value(value)
		super(value.to_s)
		@selected_label.set_string(get_value)
	end

	def gui_render!
		with_gui_object_properties {
			with_color(VALUE_COLOR) {
				render_progress_bar_with_cache($engine.slider_value(get_value))
			}
			@selected_label.gui_render!
		}
	end

	def step_amount
		1
	end
end
