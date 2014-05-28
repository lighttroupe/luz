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
