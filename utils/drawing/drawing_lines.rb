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

module DrawingLines
	$line_width_stack ||= []
	def with_line_width(width)
		GL.LineWidth(width)
			$line_width_stack.push(width)
			yield
			$line_width_stack.pop
		GL.LineWidth($line_width_stack.last || 1.0)
	end

	def draw_line(x1,y1,x2,y2)
		GL.Begin(GL::LINES)
			GL.Vertex(x1,y1)
			GL.Vertex(x2,y2)
		GL.End
	end
end
