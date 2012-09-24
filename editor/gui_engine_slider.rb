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

	VALUE_COLOR = [0.0, 0.0, 0.4, 0.8]
	def gui_render!
		with_gui_object_properties {
			with_vertical_clip_plane_right_of($engine.slider_value(get_value) - 0.5) {
				with_color(VALUE_COLOR) {
					unit_square
				}
			}

			@selected_label.gui_render!
		}
	end

	def step_amount
		1
	end
end
