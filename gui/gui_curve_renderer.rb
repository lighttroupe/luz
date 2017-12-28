class GuiCurveRenderer < GuiUserObjectRenderer
	UP_COLOR = [0.35, 0.75, 0.25, 1.0]
	DOWN_COLOR = [0.80, 0.0, 0.0, 1.0]
	MIDDLE_COLOR = [0.95, 0.50, 0.0, 1.0]
	LOOPING_COLOR = [0.8, 0.8, 0.0, 1.0]
	MISC_COLOR = [0.5, 0.5, 0.8, 1.0]
	FLOOR_COLOR = [0.0, 0.0, 0.0, 0.9]

	POINTS_IN_ICON = 200

	#
	# Rendering
	#
	def gui_render
		gui_render_background
		gui_render_curve
	end

private

	def gui_render_curve
		with_color(gui_icon_color) {
			@object.gui_render_list = GL.RenderCached(@object.gui_render_list) {
				with_translation(-0.5, -0.5) {
					vertices = []
					GL.Begin(GL::TRIANGLE_STRIP)
						GL.Vertex(0.0, 0.0)
						POINTS_IN_ICON.times { |i|
							GL.Vertex(x=(i * 1.0/POINTS_IN_ICON), @object.value(x))
							GL.Vertex(((i+1) * 1.0/POINTS_IN_ICON), 0.0)
						}
						GL.Vertex(1.0, @object.value(1.0))
						GL.Vertex(1.0, 0.0)
					GL.End
				}
			}
		}
	end

	def gui_icon_color
		if @object.up?					# lower left to upper right (/)
			UP_COLOR
		elsif @object.down?			# upper left to lower right (\)
			DOWN_COLOR
		elsif @object.middle?		# starts and ends on 0.5 (~)
			MIDDLE_COLOR
		elsif @object.looping?	# starts and ends on same value
			LOOPING_COLOR
		else						# anything else
			MISC_COLOR
		end
	end
end
