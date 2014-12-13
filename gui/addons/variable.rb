class Variable
	PROGRESS_BAR_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render!
		gui_render_background
		gui_render_progress_bar if enabled?
		gui_render_label
	end

	def gui_render_progress_bar
		with_color(PROGRESS_BAR_COLOR) {
			render_progress_bar_with_cache(do_value)
		}
	end
end
