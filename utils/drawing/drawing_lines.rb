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
