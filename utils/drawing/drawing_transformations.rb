module DrawingTransformations
	def with_translation(x, y, z=0.0)
		return yield if x == 0.0 and y == 0.0 and z == 0.0

		GL.SaveMatrix {
			GL.Translate(x, y, z)
			yield
		}
	end

	# Variation of translate, moves "forward" (towards higher Y values)
	def with_slide(amount)
		return yield if amount == 0.0

		GL.SaveMatrix {
			GL.Translate(0.0, amount, 0.0)
			yield
		}
	end

	def with_angle_slide(angle, distance)
		return yield if distance == 0.0

		# Rotate, send object out to its orbit, then rotate the other way so
		# the object doesn't appear to have rotated at all.
		GL.SaveMatrix {
			GL.Rotate(angle * FUZZY_TO_DEGREES, 0.0, 0.0, 1.0) 	# Rotate around the Z axis
			GL.Translate(0, distance, 0)
			GL.Rotate(-angle * FUZZY_TO_DEGREES, 0.0, 0.0, 1.0)	# Inverse of above
			yield
		}
	end

	def with_roll(amount, x=0.0, y=0.0, z=1.0)
		return yield if amount == 0.0

		GL.SaveMatrix {
			GL.Rotate(amount * FUZZY_TO_DEGREES, x, y, z) 	# Rotate around the Z axis
			yield
		}
	end

	def with_pitch(amount)
		return yield if amount == 0.0

		GL.SaveMatrix {
			GL.Rotate(amount * FUZZY_TO_DEGREES, 1.0, 0.0, 0.0)
			yield
		}
	end

	def with_yaw(amount)
		return yield if amount == 0.0

		GL.SaveMatrix {
			GL.Rotate(amount * FUZZY_TO_DEGREES, 0.0, 1.0, 0.0)
			yield
		}
	end

	$accumulated_scale_x = 1.0
	$accumulated_scale_y = 1.0

	def with_aspect_ratio_fix
		# make object as wide as it is tall, in screen coordinates
		fix = ($accumulated_scale_y / $accumulated_scale_x)
		with_scale(fix, 1.0) {
			# assert_equal 1.0, ($accumulated_scale_x / $accumulated_scale_y)
			yield
		}
	end

	def with_aspect_ratio_fix_y
		# make object as tall as it is wide, in screen coordinates
		fix = $accumulated_scale_x / $accumulated_scale_y
		with_scale(1.0, fix) {
			# assert_equal 1.0, ($accumulated_scale_x / $accumulated_scale_y)
			yield fix
		}
	end

	def with_scale(x, y=nil, z=nil)
		y ||= x		# When only one is given, scale equally x and y
		z ||= 1.0		# When only one is given, scale equally x and y

		# Special-case very common values...
		return yield if x == 1.0 and y == 1.0 and z == 1.0

		GL.SaveMatrix {
			$accumulated_scale_x = (saved_x = $accumulated_scale_x) * x
			$accumulated_scale_y = (saved_y = $accumulated_scale_y) * y
			GL.Scale(x, y, z)
			yield
			$accumulated_scale_x = saved_x
			$accumulated_scale_y = saved_y
		}
	end
	def with_scale_unsafe(x, y=nil, z=nil)
		y ||= x
		z ||= 1.0
		return yield if x == 1.0 and y == 1.0 and z == 1.0
		GL.Scale(x, y, z)
		yield
	end

	def with_identity_transformation
		GL.PushMatrix		# push modelview
		GL.MatrixMode(GL::PROJECTION)
		GL.PushMatrix		# push projection

		$engine.set_opengl_projection		# TODO: shouldn't reference $engine here, instead have a way to store defaults
		$engine.set_opengl_view

		yield

		GL.MatrixMode(GL::PROJECTION)
		GL.PopMatrix		# pop projection
		GL.MatrixMode(GL::MODELVIEW)
		GL.PopMatrix
	end

	def current_xyz_translation
		# "The translation components occupy the 13th, 14th, and 15th elements of the 16-element matrix" from http://www.opengl.org/resources/faq/technical/transformations.htm
		matrix = GL.GetDoublev(GL::MODELVIEW_MATRIX)
		a = matrix.last
		return a[0], a[1], a[2] + 0.5
	end
end
