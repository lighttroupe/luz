class Event
	GUI_COLOR_ON = [1.0,1.0,0.0,1.0]
	GUI_COLOR_OFF = [1.0,1.0,0.0,0.1]

	def gui_render!
		gui_render_background

		# Status Indicator
		with_translation(-0.5 + 0.1, 0.0) {
			with_scale(0.1, 0.35) {
				with_color(now? ? GUI_COLOR_ON : GUI_COLOR_OFF) {
					unit_square
				}
			}
		}

		# Label
		with_translation(0.23, 0.05) {
			gui_render_label
		}
	end
end
