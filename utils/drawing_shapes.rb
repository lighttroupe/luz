 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

module DrawingShapes
	def unit_square
		@unit_square_list ||= GL.RenderToList {
			GL.Begin(GL::TRIANGLE_FAN)
				GL.TexCoord(0.0, 0.0) ; GL.Vertex(-0.5, 0.5)
				GL.TexCoord(1.0, 0.0) ; GL.Vertex(0.5, 0.5)
				GL.TexCoord(1.0, 1.0) ; GL.Vertex(0.5, -0.5)
				GL.TexCoord(0.0, 1.0) ; GL.Vertex(-0.5, -0.5)
			GL.End
		}
		GL.CallList(@unit_square_list)
	end
	alias :fullscreen_rectangle :unit_square

	def unit_square_outline
		@unit_square_outline_list ||= GL.RenderToList {
			GL.Begin(GL::LINE_LOOP)
				GL.Vertex(-0.5, 0.5)
				GL.Vertex(0.5, 0.5)
				GL.Vertex(0.5, -0.5)
				GL.Vertex(-0.5, -0.5)
			GL.End
		}
		GL.CallList(@unit_square_outline_list)
	end
	alias :fullscreen_rectangle :unit_square
end
