class	GuiVariableInputRenderer < GuiChildUserObjectRenderer
	PROGRESS_BAR_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render
		gui_render_background
		gui_render_progress_bar if @object.enabled?
		gui_render_label
		gui_render_enable_checkbox
	end

	def gui_render_progress_bar
		with_translation(enable_checkbox.scale_x / 2.0, 0.0) {
			with_scale_unsafe(1.0 - enable_checkbox.scale_x, 1.0) {
				with_color(PROGRESS_BAR_COLOR) {
					render_progress_bar_with_cache(do_value)
				}
			}
		}
	end
end
