module DrawingScreen
	def clear_screen(color)
		GL.ClearColor(*(color.to_a))
		GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
	end

	def fade_screen_to_color(color, amount)		# This turned out to be a bit slower
		return if amount == 0.0
		return clear_screen(color) if amount == 1.0

		a = color.to_a
		with_color_and_alpha([a[0], a[1], a[2], 1.0]) {
			GL.DepthMask(GL::FALSE)
			with_identity_transformation {
				with_gl_blend_function(GL::CONSTANT_ALPHA, GL::ONE_MINUS_CONSTANT_ALPHA) {
					GL.BlendColor(0,0,0,amount)		# Set the "constant alpha"
					fullscreen_rectangle
					GL.BlendColor(0,0,0,0)
				}
			}
			GL.DepthMask(GL::TRUE)
		}
		GL.Clear(GL::DEPTH_BUFFER_BIT)
	end

	def fade_screen_to_color_with_alpha_blend(color, amount)
		return if amount == 0.0
		return clear_screen(color) if amount == 1.0

		a = color.to_a
		with_color_and_alpha([a[0], a[1], a[2], amount]) {
			GL.DepthMask(GL::FALSE)
			with_identity_transformation {
				fullscreen_rectangle
			}
			GL.DepthMask(GL::TRUE)
		}
		GL.Clear(GL::DEPTH_BUFFER_BIT)
	end
end
