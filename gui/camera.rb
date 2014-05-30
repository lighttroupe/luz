class GLCamera
	POSITION_ANIMATION_TIME = 0.2
	PROGRESS_PER_FRAME = 0.12
	MIN_DISTANCE = 0.001

	include Drawing

	def initialize
		@position = Vector3.new(0,0,0.5)
		@look_vector = Vector3.new(0,0,-1.0)
		@up_vector = Vector3.new(0,1,0)
		@new_position = @position.dup
	end

	def using
		GL.Translate(0,0,0.5)		# HACK: undo built in translate

		if @new_position != @position
			towards = @new_position - @position
			@position = @position + (towards * PROGRESS_PER_FRAME)
			#$gui.positive_message "stop" if towards.length < MIN_DISTANCE
			@position = @new_position if towards.length < MIN_DISTANCE
		end

		GL.SaveMatrix {
			GLU.LookAt(@position.x, @position.y, @position.z, @position.x+@look_vector.x, @position.y+@look_vector.y, @position.z+@look_vector.z, @up_vector.x, @up_vector.y, @up_vector.z)
			yield
		}
	end

	#
	# Vector helpers
	#
	def left_vector
		@up_vector.cross(@look_vector)
	end

	#
	# Movement
	#
	def move_forward(amount)
		@new_position = @new_position + (@look_vector * amount)
	end
	def move_left(amount)
		@new_position = @new_position + (left_vector * amount)
	end
	def move_up(amount)
		@new_position = @new_position + (@up_vector * amount)
	end
end
