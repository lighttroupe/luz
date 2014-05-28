module DrawingStencilBuffer
	def with_stencil_buffer
		return yield if GL.IsEnabled(GL::STENCIL_TEST)

		GL.Enable(GL::STENCIL_TEST)
		yield
		GL.Disable(GL::STENCIL_TEST)
	end

	def with_stencil_buffer_for_writing(options = {})
		$next_stencil_buffer_index ||= 0

		# Select stencil buffer
		with_stencil_buffer {
			GL.StencilMask(1 << $next_stencil_buffer_index)

			# Clear stencil buffer
			GL.ClearStencil(0)
			GL.Clear(GL::STENCIL_BUFFER_BIT)

			GL.StencilOp(GL::REPLACE, GL::REPLACE, GL::REPLACE)
			GL.StencilFunc(GL::ALWAYS, 0x00000001, 0x00000001)

			# Don't write to color buffer
			GL.ColorMask(false, false, false, false)
			GL.DepthMask(false)

			with_alpha_test(options[:alpha_cutoff] || 0.0) {
				$next_stencil_buffer_index += 1
				yield
				$next_stencil_buffer_index -= 1
			}

			GL.DepthMask(true)
			GL.ColorMask(true, true, true, true)
			GL.StencilMask(0x00000000)
		}
	end

	def with_stencil_buffer_filter
		$next_stencil_buffer_index ||= 0

		with_stencil_buffer {
			GL.StencilMask(1 << $next_stencil_buffer_index)
			GL.StencilFunc(GL::EQUAL, 0x00000001, 0x00000001)

			$next_stencil_buffer_index += 1
			yield
			$next_stencil_buffer_index -= 1

			GL.StencilMask(0x00000000)
		}
	end
end
