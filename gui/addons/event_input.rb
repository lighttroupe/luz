class EventInput
	GUI_COLOR_ON = [1.0,1.0,0.0,1.0]
	GUI_COLOR_OFF = [1.0,1.0,0.0,0.1]

	def gui_render!
		gui_render_background

		gui_render_on_off_state

		# Label shifted to accomidate on/off state
		with_translation(0.17, 0.05) {
			gui_render_label
		}

		gui_render_enable_checkbox
	end

	def gui_render_on_off_state
		# Status Indicator
		with_translation(-0.5 + 0.1, 0.0) {
			with_scale(0.1, 0.35) {
				with_color(now? ? GUI_COLOR_ON : GUI_COLOR_OFF) {
					unit_square
				}
			}
		}
	end
end
