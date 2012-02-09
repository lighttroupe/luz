 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
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

class DirectorEffectCamera < DirectorEffect
	title				"Camera"
	description "Sets camera position, pitch, roll, yaw."

	hint "Place above effects that draw actors in the effects list."

	setting 'x', :float, :default => 0.0..1.0
	setting 'y', :float, :default => 0.0..1.0
	setting 'z', :float, :default => 0.0..1.0
	setting 'roll', :float, :default => 0.0..1.0
	setting 'pitch', :float, :default => 0.0..1.0
	setting 'yaw', :float, :default => 0.0..1.0

	setting 'width', :float, :range => 0.1..10.0, :default => 1.0..2.0
	setting 'height', :float, :range => 0.1..10.0, :default => 1.0..2.0

	def render
		if $env[:hit_test]
			# render nothing when hit testing
			yield

		elsif $env[:stage]
			yield

			# render a camera at its location
			GL.SaveMatrix {
				with_translation(x, y, z) {
					with_pitch(pitch) {
						with_yaw(yaw) {
							with_roll(roll) {
								with_scale(width, height) {
									draw_camera
								}
							}
						}
					}
				}
			}

		else
			# render via the camera
			GL.MatrixMode(GL::PROJECTION)
			GL.SaveMatrix {
				GLU.LookAt(
					x, y, z,
					x + (fuzzy_sine(-yaw + 0.5) - 0.5), y + (fuzzy_sine(-pitch + 0.5) - 0.5), -1, 		# TODO: look at appropriate point
					0, 1, 0) 		# up vector positive Y up vector

				with_roll(-roll) {
					GL.MatrixMode(GL::MODELVIEW)
						with_scale(1.0/width, 1.0/height) {
							yield
						}
					GL.MatrixMode(GL::PROJECTION)
				}
			}
			GL.MatrixMode(GL::MODELVIEW)
		end
	end

	def draw_camera
		far_z = 5
		half_height = 5.5 #* (height.to_f / width.to_f)
		half_width = 5.5 #* (height.to_f / width.to_f)

		# a unit square on the origin 0, 0, 0
		unit_square_outline

		@camera_distance_from_origin = 0.5
		GL.Begin(GL::LINES)
			GL.Vertex(0.0, 0.0, @camera_distance_from_origin) ; GL.Vertex(half_width, half_height, -far_z)
			GL.Vertex(0.0, 0.0, @camera_distance_from_origin) ; GL.Vertex(half_width, -half_height, -far_z)
			GL.Vertex(0.0, 0.0, @camera_distance_from_origin) ; GL.Vertex(-half_width, -half_height, -far_z)
			GL.Vertex(0.0, 0.0, @camera_distance_from_origin) ; GL.Vertex(-half_width, half_height, -far_z)
		GL.End

		GL.Begin(GL::LINE_LOOP)
			GL.Vertex(half_width, half_height, -far_z)
			GL.Vertex(half_width, -half_height, -far_z)
			GL.Vertex(-half_width, -half_height, -far_z)
			GL.Vertex(-half_width, half_height, -far_z)
		GL.End

		GL.Begin(GL::POINTS) ; GL.Vertex(0.0, 0.0, @camera_distance_from_origin) ; GL.End
	end
end

