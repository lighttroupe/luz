#
# Drawing of the X,Y,Z axes
#
class CartesianScaffolding
	MAJOR_GRIDLINE_COLOR = Color.new([1.0, 1.0, 1.0, 0.3])

	include Drawing

	def render
		draw_scaffolding
	end

private

	def draw_scaffolding
		# Paint the scaffolding, writing and testing depths
		GL.Enable(GL::DEPTH_TEST)
		GL.DepthMask(true)				# write depths
		GL.DepthFunc(GL::LEQUAL)	# nearer or newer

		GL.LineWidth(1.0)
		GL.PointSize(3.0)
		draw_origin_cross

		with_color(MAJOR_GRIDLINE_COLOR) {
			GL.LineWidth(1.0)
			with_roll(0.25, x=1.0, y=0.0, z=0.0) {
				with_scale(10) {
					draw_grid(10)
				}
			}
		}
		GL.Disable(GL::DEPTH_TEST)
	end

	def draw_origin_cross(distance=5.0)
		alpha = 0.9
#		@origin_cross_list ||= {}
#		@origin_cross_list[distance] ||= GL.RenderToList {
			with_color([1.0, 0.0, 0.0, alpha]) { draw_origin_line_x(distance) }
			with_color([0.0, 1.0, 0.0, alpha]) { with_roll(0.25, 0.0, 0.0, 1.0) { draw_origin_line_x(distance) } }
			with_color([0.0, 0.0, 1.0, alpha]) { with_roll(0.25, 0.0, 1.0, 0.0) { draw_origin_line_x(distance) } }
#		}
#		GL.CallList(@origin_cross_list[distance])
	end

	def draw_origin_line_x(distance)
		GL.Begin(GL::LINES)
			GL.Vertex(distance, 0.0, 0.0) ; GL.Vertex(-distance, 0.0, 0.0)
		GL.End

		GL.Begin(GL::POINTS)
			(-distance).step(distance, 0.5) { |d| GL.Vertex(d, 0.0, 0.0) }
		GL.End
	end

	def draw_grid(grid_lines)
		GL.Begin(GL::LINES)
			(-0.5).step(0.5, 1.0 / grid_lines) { |x| GL.Vertex(x, 0.5) ; GL.Vertex(x, -0.5) }
			(-0.5).step(0.5, 1.0 / grid_lines) { |y| GL.Vertex(0.5, y) ; GL.Vertex(-0.5, y) }
		GL.End
	end
end
