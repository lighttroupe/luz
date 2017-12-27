#
# GuiVariableRenderer renders a Variable (in lists)
#
class	GuiVariableRenderer < GuiUserObjectRenderer
	PROGRESS_BAR_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render
		gui_render_background
		gui_render_progress_bar if @object.enabled?
		gui_render_label
	end

private

	def label_width
		9
	end

	def gui_render_progress_bar
		with_color(PROGRESS_BAR_COLOR) {
			render_progress_bar_with_cache(@object.do_value)
		}
	end

	def gui_render_label
		with_translation(0.01, 0.0) {		# TODO: just set label widget values in create()
			with_scale(0.95, 1.0) {
				super
			}
		}
	end
end
