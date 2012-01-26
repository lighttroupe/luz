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
