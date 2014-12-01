class VariableInput
	GUI_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render!
		gui_render_background
		with_translation(enable_checkbox.scale_x / 2.0, 0.0) {
			with_scale_unsafe(1.0 - enable_checkbox.scale_x, 1.0) {
				gui_render_activation
			}
		}
		gui_render_label
		gui_render_enable_checkbox
	end

	def gui_render_activation		# fills 1x1
		# Status Indicator
		if enabled? && (v=do_value) > 0.0
			with_translation(-0.5 + v/2.0, 0.0) {
				with_scale_unsafe(v, 1.0) {
					with_color(GUI_COLOR) {
						unit_square
					}
				}
			}
		end
	end
end
