class Variable
	GUI_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render!
		gui_render_background
		render_bar_value_with_cache(do_value) if enabled?
		gui_render_label
	end

	def render_bar_value_with_cache(value)
		cache_key = (1000 * value).to_i		# TODO: 1000 display lists to draw bars might be overkill
		@@value_list_cache ||= Hash.new
		@@value_list_cache[cache_key] ||= GL.RenderToList { render_bar(value) }
		GL.CallList(@@value_list_cache[cache_key])
	end

	def render_bar(value)
		if value > 0.0
			with_translation(-0.5 + value/2.0, 0.0) {
				with_scale_unsafe(value, 1.0) {
					with_color_listsafe(GUI_COLOR) {
						unit_square
					}
				}
			}
		end
	end
end
