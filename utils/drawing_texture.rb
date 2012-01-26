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

module DrawingTexture
	$texture_id_stack ||= []
	def with_texture(id)
		return yield unless id

		GL.BindTexture(GL::TEXTURE_2D, id)
		$texture_id_stack.push(id)
		yield
		$texture_id_stack.pop
		GL.BindTexture(GL::TEXTURE_2D, $texture_id_stack.last || 0)
	end

	def with_texture_scale(x_scale, y_scale)
		GL.MatrixMode(GL::TEXTURE)
			GL.SaveMatrix {
				GL.Scale(x_scale, y_scale, 1)

				GL.MatrixMode(GL::MODELVIEW)
					yield
				GL.MatrixMode(GL::TEXTURE)
			}
		GL.MatrixMode(GL::MODELVIEW)
	end

	def with_texture_scale_and_translate(x_scale, y_scale, x_translate, y_translate)
		GL.MatrixMode(GL::TEXTURE)
			GL.SaveMatrix {
				GL.Scale(x_scale, y_scale, 1)
				GL.Translate(x_translate, y_translate, 0)

				GL.MatrixMode(GL::MODELVIEW)
					yield
				GL.MatrixMode(GL::TEXTURE)
			}
		GL.MatrixMode(GL::MODELVIEW)
	end
end
