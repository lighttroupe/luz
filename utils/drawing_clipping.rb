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

	def with_clip_box(radius = 0.5)
		with_vertical_clip_plane_left_of(-radius) {
			with_vertical_clip_plane_right_of(radius) {
				with_horizontal_clip_plane_below(-radius) {
					with_horizontal_clip_plane_above(radius) {
						yield
					}
				}
			}
		}
	end

end
