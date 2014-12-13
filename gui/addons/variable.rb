class Variable
	GUI_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render!
		gui_render_background
		gui_render_bar(do_value) if enabled?
		gui_render_label
	end

	def gui_render_bar(value)
		with_color(GUI_COLOR) {
			render_progress_bar_with_cache(value)
		}
	end
end
