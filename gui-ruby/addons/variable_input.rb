class VariableInput
	GUI_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render!
		gui_render_background

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

		# Label
		gui_render_label
	end
end
