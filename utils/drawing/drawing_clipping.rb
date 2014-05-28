module DrawingClipping
	def with_clip_plane(plane)
		$clip_plane_count ||= GL.GetIntegerv(GL::MAX_CLIP_PLANES)
		$next_clip_plane_index ||= 0

		return yield if $next_clip_plane_index == $clip_plane_count

		GL.Enable(GL::CLIP_PLANE0 + $next_clip_plane_index)
		GL.ClipPlane(GL::CLIP_PLANE0 + $next_clip_plane_index, plane)
		$next_clip_plane_index += 1
		yield
		$next_clip_plane_index -= 1
		GL.Disable(GL::CLIP_PLANE0 + $next_clip_plane_index)
	end
	#conditional :with_clip_plane

	def with_clip_plane_left_of_angle(fuzzy_angle, &proc)
		radians = RADIANS_UP + (fuzzy_angle * RADIANS_PER_CIRCLE)
		with_clip_plane([-Math.sin(radians), -Math.cos(radians), 0.0, 0.0], &proc)
	end

	def with_clip_plane_right_of_angle(fuzzy_angle, &proc)
		radians = RADIANS_UP + (fuzzy_angle * RADIANS_PER_CIRCLE)
		with_clip_plane([Math.sin(radians), Math.cos(radians), 0.0, 0.0], &proc)
	end

	def with_vertical_clip_plane_left_of(x, &proc)
		with_clip_plane([1.0, 0.0, 0.0, -x], &proc)
	end

	def with_vertical_clip_plane_right_of(x, &proc)
		with_clip_plane([-1.0, 0.0, 0.0, x], &proc)
	end

	def with_horizontal_clip_plane_above(y, &proc)
		with_clip_plane([0.0, -1.0, 0.0, y], &proc)
	end

	def with_horizontal_clip_plane_below(y, &proc)
		with_clip_plane([0.0, 1.0, 0.0, -y], &proc)
	end

	def with_clip_box(radius = 0.5, angle = 0.0)
		with_roll(angle) {
			with_vertical_clip_plane_left_of(-radius) {
				with_vertical_clip_plane_right_of(radius) {
					with_horizontal_clip_plane_below(-radius) {
						with_horizontal_clip_plane_above(radius) {
							with_roll(-angle) {
								yield
							}
						}
					}
				}
			}
		}
	end

end
