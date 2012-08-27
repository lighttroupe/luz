 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
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

require 'stage'
require 'vector3'

class Stage3D < Stage
	CAMERA_COLOR = Color.new([1.0, 1.0, 1.0, 0.8])

	def initialize
		super
		@free_cam = false

		@camera_position = Vector3.new(0.0, 0.0, 0.5)
		@camera_velocity = Vector3.new(0.0, 0.0, 0.0)
		@camera_focus = Vector3.new(0.0, 0.0, 0.0)

		#
		# Respond to mouse input by camera movement
		#
		on_secondary_mouse_button_down { @camera_movement_enabled = true }
		on_secondary_mouse_button_up { @camera_movement_enabled = false }
		on_mouse_motion { |x, y|
			@old_x ||= x
			@old_y ||= y

			if(@camera_movement_enabled)
				@camera_velocity.x += (x - @old_x) * 0.1
				@camera_velocity.y -= (y - @old_y) * 0.1
			end

			if @drag_object
				drag_object_to(x, y)
			end

			if(@camera_rotation_enabled)
				@camera_rotation_velocity.x += (x - @old_x) * 0.5
				@camera_rotation_velocity.y -= (y - @old_y) * 0.5
			end
			@old_x, @old_y = x, y
		}

		on_primary_mouse_button_down { |x, y| hit_test(x, y) ; render }
		on_primary_mouse_button_up { @drag_object = nil }

		on_scroll_wheel_up {
			if @drag_object
				@drag_object.handle_drag_scroll_up(@drag_handle_id)
			else
				@camera_velocity.z += 0.4 ; @camera_velocity.x += (0.8 * ((@old_x / width) - 0.5)) ; @camera_velocity.y += (0.8 * ((1.0 - (@old_y / height)) - 0.5))
			end
		}
		on_scroll_wheel_down {
			if @drag_object
				@drag_object.handle_drag_scroll_down(@drag_handle_id)
			else
				@camera_velocity.z -= 0.4		# straight back
			end
		}
	end

	def drag_object_to(x, y)
		x_percent = x / width
		y_percent = 1.0 * (y / height)

		camera_look_vector = (@camera_focus - @camera_position)
		camera_vector_up = Vector3.new(0.0, 1.0, 0.0)		# HACK: assumes camera is always pointing "up"
		camera_vector_left = camera_look_vector.cross(camera_vector_up).normalize

		pointer_vector = @camera_focus + (camera_vector_up * (0.5 - y_percent)) + (camera_vector_left * -(0.5 - x_percent))

		pt = intersect_segment_and_plane(@camera_position, pointer_vector, Vector3.new(@drag_object.x, @drag_object.y, @drag_object.z), Vector3.new(0.0, 0.0, -1.0))
		return unless pt		# no intersection ?!

		if $gui.snap_to_grid?
			@drag_object.x, @drag_object.y, @drag_object.z  = (pt.x * 10.0).round / 10.0, (pt.y * 10.0).round / 10.0, (pt.z * 10.0).round / 10.0
		else
			@drag_object.x, @drag_object.y, @drag_object.z  = pt.x, pt.y, pt.z
		end
	end

	def intersect_segment_and_plane(segment_pt0, segment_pt1, plane_pt, plane_vector)
# intersect3D_SegmentPlane(): intersect a segment and a plane
#    Input:  S = a segment, and Pn = a plane = {Point V0; Vector n;}
#    Output: *I0 = the intersect point (when it exists)
#    Return: 0 = disjoint (no intersection)
#            1 = intersection in the unique point *I0
#            2 = the segment lies in the plane
#int intersect3D_SegmentPlane( Segment S, Plane Pn, Point* I )
#{
#    Vector    u = S.P1 - S.P0;
#    Vector    w = S.P0 - Pn.V0;

		u = segment_pt1 - segment_pt0
	#puts "u = #{u}"
		w = segment_pt0 - plane_pt
	#puts "w = #{w}"

#    float     D = dot(Pn.n, u);
#    float     N = -dot(Pn.n, w);

		d = plane_vector.dot(u)
	#puts "d = #{d}"
		n = -plane_vector.dot(w)
	#puts "n = #{n}"

#    if (fabs(D) < SMALL_NUM) {          // segment is parallel to plane
#        if (N == 0)                     // segment lies in plane
#            return 2;
#        else
#            return 0;                   // no intersection
#    }

		return false if d.abs < 0.0002

#    // they are not parallel
#    // compute intersect param
#    float sI = N / D;
#    if (sI < 0 || sI > 1)
#        return 0;                       // no intersection

		sI = n / d;
	#puts "sI = #{sI}"

#		return false if sI < 0 or sI > 1

#    *I = S.P0 + sI * u;                 // compute segment intersect point
#    return 1;

		return segment_pt0 + (u * sI)
#}
	end

	def pointer_to_vector(x, y)
		@camera_position
	end

	def setup_camera
		GL.MatrixMode(GL::PROJECTION)
		GL.LoadIdentity

		@camera_distance_from_origin = 0.5		# HACK
		angle = 2.0 * Math.atan(0.5 / @camera_distance_from_origin) * RADIANS_TO_DEGREES	# TODO: comment this
		GLU.Perspective(angle, 1.0, 0.001, 1024.0) # NOTE: near/far clip plane numbers are somewhat arbitrary.

		camera_look_vector = (@camera_focus - @camera_position)
		distance_from_focus = camera_look_vector.length

#		@camera_velocity.z = 0.0 if @camera_velocity.z > 0.0 and camera_look_vector.length < 1.0
#puts @camera_velocity unless @camera_velocity.zero?

		@point_above_camera ||= Vector3.new
		@point_above_camera.set(@camera_position.x, @camera_position.y, @camera_position.z + 1.0)

		@vector_up = Vector3.new(0.0,1.0,0.0)
		vector_left = camera_look_vector.cross(@vector_up)

		# update the position
		offset = (((camera_look_vector.unit * @camera_velocity.z) + (@vector_up * @camera_velocity.y) + (vector_left.unit * @camera_velocity.x)) * $env[:frame_time_delta])
		@camera_position += offset
		@camera_focus += offset

		# damper velocity
		@camera_velocity *= 0.75
		@camera_velocity.set(0.0,0.0,0.0) if @camera_velocity.length < 0.005

		camera_look_at = @camera_position + camera_look_vector.unit

		GLU.LookAt(
			@camera_position.x, @camera_position.y, @camera_position.z,
			camera_look_at.x, camera_look_at.y, camera_look_at.z,
			0.0, 1.0, 0.0) 		# up vector positive Y up vector

		GL.MatrixMode(GL::MODELVIEW)
	end

	def draw_scaffolding
		# Paint the scaffolding, writing and testing depths
		GL.Enable(GL::DEPTH_TEST)
		GL.DepthMask(true)				# write depths
		GL.DepthFunc(GL::LEQUAL)	# nearer or newer

		GL.LineWidth(1.0)
		GL.PointSize(3.0)
		draw_origin_cross(5.0)

		with_color(MAJOR_GRIDLINE_COLOR) {
			GL.LineWidth(1.0)
			with_roll(0.25, x=1.0, y=0.0, z=0.0) {
				with_scale(10) {
					draw_grid(10)
				}
			}
		}
	end

	def render(objects=@drawn_objects)
		using_context {
			GL.PushAll {
				setup_camera

				#
				# set rendering state
				#
				settings
				clear_screen(BACKGROUND_COLOR)
				#clear_screen(@bg_colors||=Color.new([0,0,0]))

				draw_scaffolding

				# Draw actors without writing, but still testing depth against scaffolding
				GL.DepthMask(false)

				$engine.with_env(:stage, true) {
					$engine.with_env(:draw_handles, true) {
						objects.each { |object| object.render! }
					}
				}

				#draw_handles(objects)
			}
		}
		@drawn_objects = objects
	end

	def hit_test(x, y)
		with_hit_test {
#		$env[:draw_handles] = true

			using_context_without_finalize {
				GL.PushAll {
					setup_camera
					settings
					GL.ClearColor(0,0,0,0)
					GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
					@drawn_objects.each { |object| object.render! }
				}
			}

			#winZ = glReadPixels(x, y, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT).unpack("f")[0]
			#puts winZ
			@drag_object, @drag_handle_id = hit_test_object_at(x, height - y)
		}
	end

	########################################################################
	# Drawing
	########################################################################
	def draw_origin_line_x(distance)
		GL.Begin(GL::LINES)
			GL.Vertex(distance, 0.0, 0.0) ; GL.Vertex(-distance, 0.0, 0.0)
		GL.End

		GL.Begin(GL::POINTS)
			(-distance).step(distance, 0.5) { |d| GL.Vertex(d, 0.0, 0.0) }
		GL.End
	end

	def draw_origin_cross(distance)
		alpha = 0.9
#		@origin_cross_list ||= {}
#		@origin_cross_list[distance] ||= GL.RenderToList {
			with_color([1.0, 0.0, 0.0, alpha]) { draw_origin_line_x(distance) }
			with_color([0.0, 1.0, 0.0, alpha]) { with_roll(0.25, 0.0, 0.0, 1.0) { draw_origin_line_x(distance) } }
			with_color([0.0, 0.0, 1.0, alpha]) { with_roll(0.25, 0.0, 1.0, 0.0) { draw_origin_line_x(distance) } }

#		}
#		GL.CallList(@origin_cross_list[distance])
	end

	def draw_cross(distance=1.0)
		@cross_list ||= {}
		@cross_list[distance] ||= GL.RenderToList {
			GL.Begin(GL::LINES) ; GL.Vertex(distance, 0.0, 0.0) ; GL.Vertex(-distance, 0.0, 0.0) ; GL.End
			GL.Begin(GL::LINES) ; GL.Vertex(0.0, distance, 0.0) ; GL.Vertex(0.0, -distance, 0.0) ; GL.End
			GL.Begin(GL::LINES) ; GL.Vertex(0.0, 0.0, distance) ; GL.Vertex(0.0, 0.0, -distance) ; GL.End
		}
		GL.CallList(@cross_list[distance])
	end

	def draw_camera
		far_z = 5
		half_height = 5.5 #* (height.to_f / width.to_f)
		half_width = 5.5 #* (height.to_f / width.to_f)

		# a unit square on the origin 0, 0, 0
		unit_square

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
