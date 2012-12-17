class Curve
	UP_COLOR = [0.35, 0.75, 0.25, 1.0]
	DOWN_COLOR = [0.80, 0.0, 0.0, 1.0]
	MIDDLE_COLOR = [0.95, 0.50, 0.0, 1.0]
	LOOPING_COLOR = [0.8, 0.8, 0.0, 1.0]
	MISC_COLOR = [0.5, 0.5, 0.8, 1.0]
	FLOOR_COLOR = [0.0, 0.0, 0.0, 0.9]

	def gui_build_editor
		GuiObjectRenderer.new(self)
	end

	def gui_icon_color
		if up?					# lower left to upper right (/)
			UP_COLOR
		elsif down?			# upper left to lower right (\)
			DOWN_COLOR
		elsif middle?		# starts and ends on 0.5 (~)
			MIDDLE_COLOR
		elsif looping?	# starts and ends on same value
			LOOPING_COLOR
		else						# anything else
			MISC_COLOR
		end
	end

	POINTS_IN_ICON = 200

	def gui_render!
		gui_render_background

		if pointer_hovering?
			progress = ($env[:beat] % 4.0) / 4.0

			with_clip_box {
				with_scale(8.0) {
					with_translation(0.5 - progress, 0.5 - value(progress)) {
						#unit_square_outline
						with_translation(-1.0, 0.0) {
							gui_render_curve
						}
						gui_render_curve
						with_translation(1.0, 0.0) {
							gui_render_curve
						}
						with_translation(0.0, -1) {
							with_scale(3.0, 1.0) {
								with_color(FLOOR_COLOR) {
									unit_square
								}
							}
						}
					}
				}
			}

			gui_render_label
		else
			gui_render_curve
		end
	end

	def gui_render_curve
		with_color(gui_icon_color) {
			@gui_render_list = GL.RenderCached(@gui_render_list) {
				with_translation(-0.5, -0.5) {
					vertices = []
					GL.Begin(GL::TRIANGLE_STRIP)
						GL.Vertex(0.0, 0.0)
						POINTS_IN_ICON.times { |i|
							GL.Vertex(x=(i * 1.0/POINTS_IN_ICON), value(x))
							GL.Vertex(((i+1) * 1.0/POINTS_IN_ICON), 0.0)
						}
						GL.Vertex(1.0, value(1.0))
						GL.Vertex(1.0, 0.0)
					GL.End
				}
			}
		}
	end
end
