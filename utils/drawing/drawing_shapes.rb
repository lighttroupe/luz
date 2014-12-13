require 'gl_shapes'

module DrawingShapes
	def unit_square
		@unit_square_list = GL.RenderCached(@unit_square_list) {
			GL.Begin(GL::TRIANGLE_FAN)
				GL.TexCoord(0.0, 0.0) ; GL.Vertex(-0.5, 0.5)
				GL.TexCoord(1.0, 0.0) ; GL.Vertex(0.5, 0.5)
				GL.TexCoord(1.0, 1.0) ; GL.Vertex(0.5, -0.5)
				GL.TexCoord(0.0, 1.0) ; GL.Vertex(-0.5, -0.5)
			GL.End
		}
	end
	alias :fullscreen_rectangle :unit_square

	def unit_square_outline
		@unit_square_outline_list = GL.RenderCached(@unit_square_outline_list) {
			GL.Begin(GL::LINE_LOOP)
				GL.Vertex(-0.5, 0.5)
				GL.Vertex(0.5, 0.5)
				GL.Vertex(0.5, -0.5)
				GL.Vertex(-0.5, -0.5)
			GL.End
		}
	end

	def render_progress_bar_with_cache(value)
		cache_key = (1000 * value).to_i		# TODO: 1000 display lists to draw bars might be overkill
		@@value_list_cache ||= Hash.new
		@@value_list_cache[cache_key] ||= GL.RenderToList { render_progress_bar_without_cache(value) }
		GL.CallList(@@value_list_cache[cache_key])
	end

	def render_progress_bar_without_cache(value)
		if value > 0.0
			with_translation(-0.5 + value/2.0, 0.0) {
				with_scale_unsafe(value, 1.0) {
					unit_square
				}
			}
		end
	end
end
