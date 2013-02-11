class Variable
	GUI_COLOR = [0.0,1.0,0.5,0.7]
	MARKER_COLOR = [0.8,0.0,0.0,0.15]

	def gui_render!
		gui_render_background

		value = do_value

		render_bar_value_with_cache(value)
		render_text_value_with_cache(value)

		# Label
		gui_render_label
	end

	def render_bar_value_with_cache(value)
		cache_key = (1000 * value).to_i
		@@value_list_cache ||= Hash.new
		@@value_list_cache[cache_key] ||= GL.RenderToList { render_bar(value) }
		GL.CallList(@@value_list_cache[cache_key])
	end

	def render_text_value_with_cache(value)
		cache_key = (100 * value).to_i
		@@text_list_cache ||= Hash.new
		@@text_list_cache[cache_key] ||= GL.RenderToList { render_text(cache_key) }
		GL.CallList(@@text_list_cache[cache_key])
	end

	def render_text(value)
		@value_label ||= BitmapFont.new.set(:scale_x => 0.35, :scale_y => 0.35)
		with_translation(0.45, 0.25) {
			@value_label.set_string("#{value}%")
			@value_label.gui_render!
		}
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
