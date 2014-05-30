class GLCamera
	def initialize
		@position = Vector3.new(0,0,0.5)
		@look_at = Vector3.new(0,0,0)
	end

	include Drawing
	def using
		GL.Translate(0,0,0.5)		# HACK: undo built in translate

		GL.SaveMatrix {
			GLU.LookAt(@position.x, @position.y, @position.z, @look_at.x, @look_at.y, @look_at.z, 0, 1, 0)
			yield
		}
	end
end

# Add animation of position, etc.
class Camera < GLCamera
end
