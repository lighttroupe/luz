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
	alias :fullscreen_rectangle :unit_square
end
