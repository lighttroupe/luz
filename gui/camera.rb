class GLCamera
	def initialize
		@position = Vector3.new(0,0,0.5)
		@look_at = Vector3.new(0,0,0)
		@up_vector = Vector3.new(0,1,0)
	end

	include Drawing
	def using
		GL.Translate(0,0,0.5)		# HACK: undo built in translate

		GL.SaveMatrix {
			GLU.LookAt(@position.x, @position.y, @position.z, @look_at.x, @look_at.y, @look_at.z, @up_vector.x, @up_vector.y, @up_vector.z)
			yield
		}
	end

	#
	# Vector helpers
	#
	def look_vector
		@look_at - @position
	end
	def left_vector
		Vector3.new(-1,0,0)		# TODO
	end

	#
	# Movement
	#
	def move_forward(amount)
		v = look_vector
		@position = @position + (look_vector * amount)
		@look_at = @position + v
	end
	def move_left(amount)
		v = look_vector
		@position = @position + (left_vector * amount)
		@look_at = @position + v
	end
	def move_up(amount)
		v = look_vector
		@position = @position + (@up_vector * amount)
		@look_at = @position + v
	end
end
