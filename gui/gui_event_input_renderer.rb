class	GuiEventInputRenderer < GuiChildUserObjectRenderer
	GUI_COLOR_ON = [1.0,1.0,0.0,1.0]
	GUI_COLOR_OFF = [1.0,1.0,0.0,0.1]

	def gui_render
		gui_render_background
		gui_render_label
		gui_render_on_off_state
		gui_render_enable_checkbox
	end

private

	def gui_render_label
		with_translation(-0.05, 0.0) {
			with_scale(0.9, 1.0) {
				super
			}
		}
	end

	def gui_render_on_off_state
		with_translation(0.5 - 0.05, 0.0) {
			with_scale(0.05, 0.35) {
				with_color(@object.now? ? GUI_COLOR_ON : GUI_COLOR_OFF) {
					unit_square
				}
			}
		}
	end
end
