class Theme
	#
	# Rendering
	#
	def gui_render
		gui_render_styles
		gui_render_label if pointer_hovering?
	end

private

	def clear_render_styles_cache!
		GL.DestroyList(@gui_render_styles_list)
		@gui_render_styles_list = nil
	end

	def gui_render_styles
		@gui_render_styles_list = GL.RenderCached(@gui_render_styles_list) {
			if effects.size > 8
				num_rows = 4
			else
				num_rows = 2
			end
			num_columns = num_rows * 2

			width = 1.0 / num_columns
			height = 1.0 / num_rows

			with_scale(width, height) {
				with_translation(-num_columns/2.0 + 0.5, -num_rows/2.0 - 0.5) {
					index = 0
					for y in (0...num_rows)
						for x in (0...num_columns)
							with_translation(x, (num_rows - y)) {
								break if index >= effects.size
								with_scale(0.85) {
									effects[index].gui_render
								}
							}
							index += 1
						end
					end
				}
			}
		}
	end
end
