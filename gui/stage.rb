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

require 'gtk_gl_drawing_area'

class Stage < GtkGLDrawingArea
	include Drawing

	attr_accessor :perspective, :zoom

	#MINOR_GRIDLINE_COLOR = Color.new([0.0, 0.0, 0.0, 0.05])
	#MAJOR_GRIDLINE_COLOR = Color.new([0.1, 0.1, 0.1, 0.2])
	MAJOR_GRIDLINE_COLOR = Color.new([1.0, 1.0, 1.0, 0.3])
	BACKGROUND_COLOR = Color.new([0.25, 0.25, 0.25, 1.0])
	#BACKGROUND_COLOR = Color.new([0.0, 0.0, 0.0, 1.0])

	MAX_ZOOM = 16.0
	GRAB_DISTANCE = 5
	SNAP_DISTANCE = 4

	GRID_SQUARES = 10
	SNAP_SQUARES = 20
	BACKGROUND_REPEAT = 10

	BACKGROUND_PATTERN_TEXTURE = 'background.png'

	def initialize
		@zoom = 1.0
		@always_snap = false #true # TODO: currently no way for user to control this

		super

		on_primary_mouse_button_down { |x, y| @grab_object, @grab_type = grab_control_point(x,y) }
		on_mouse_motion { |x, y| drag_object_control_point(@grab_object, @grab_type, x, y) if @grab_object }
		on_primary_mouse_button_up { @grab_object = nil }
	end

	def zoom=(rhs)
		@zoom = rhs.clamp(1.0 / MAX_ZOOM, 1.0)
	end

private

	# Returns [actor, type of grab] or [nil, nil]
	def grab_control_point(x,y)
		@drawn_objects.each { |object|
			return [object, :move] if point_hit(x,y, *world_to_window_coordinates(object.x, object.y))
			#return [object, :resize] if point_hit(x,y, *world_to_window_coordinates(object.x + (object.width / 2), object.y + (object.height / 2)))
		}
		return [nil, nil]
	end

	def point_hit(x1,y1, x2,y2)
		return ((x1 - x2).abs < GRAB_DISTANCE and (y1 - y2).abs < GRAB_DISTANCE)
	end

	def drag_object_control_point(object, type, window_x, window_y)
		world_x, world_y = window_to_world_coordinates(*snap_window_coordinates(window_x, window_y))

		case type
		when :move
			object.x, object.y = world_x, world_y
			$engine.project.changed!

		#when :resize
			#radius_x = (world_x - object.x).clamp(0.01, 100.0)
			#radius_y = (world_y - object.y).clamp(0.01, 100.0)

			#object.width, object.height = radius_x * 2, radius_y * 2
		end
	end

	def projection
		GL.MatrixMode(GL::PROJECTION)
		GL.LoadIdentity
		GLU.Ortho2D(*@perspective)
	end

	def view
		GL.MatrixMode(GL::MODELVIEW)
		GL.LoadIdentity
	end

	def settings
		#GL.Enable(GL::BLEND)

		GL.Enable(GL::BLEND)
		GL.BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)

		# This hint can improve speed of texturing when using glOrtho() projection.
		GL.Hint(GL::PERSPECTIVE_CORRECTION_HINT, GL::FASTEST)

		# Fast blending
		#GL.Hint(GL::BLEND, GL::FASTEST) 	# TODO: make it a user setting

		GL.ShadeModel(GL::FLAT)		# TODO: probably want to change this

		# OUTDATED:	When using painter's algorithm, no need for depth test

		GL.Disable(GL::DEPTH_TEST)
		GL.DepthFunc(GL::LESS)

		#	Many effects rely on the backface to be visible (flip_horizontally)
		GL.Disable(GL::CULL_FACE)

		GL.PolygonMode(GL::FRONT, GL::FILL)
		GL.PolygonMode(GL::BACK, GL::FILL)

		#
		GL.Enable(GL::TEXTURE_2D)
	end

	def window_to_world_coordinates(x,y)
		return (x.to_f / width).scale(@perspective[0], @perspective[1]) / @zoom, (1.0 - (y.to_f / height)).scale(@perspective[2], @perspective[3]) / @zoom
	end

	def world_to_window_coordinates(x,y)
		return ((x * @zoom) + 0.5).scale(0, width), ((y * @zoom) + 0.5).scale(height, 0)	# NOTE: flipped Y
	end

	def snap_window_coordinates(x, y)
		return x, y unless $gui.snap_to_grid?

		snap_x, snap_y = (width.to_f / SNAP_SQUARES) * @zoom, (height.to_f / SNAP_SQUARES) * @zoom

		square_index_x, remainder_x = x.divmod(snap_x)
		square_index_y, remainder_y = y.divmod(snap_y)

		# Add one if we are close from the low side (the 'mod' above always rounds down)
		square_index_x += 1 if remainder_x > (snap_x - SNAP_DISTANCE)
		square_index_y += 1 if remainder_y > (snap_y - SNAP_DISTANCE)

		snap_spot_x = square_index_x * snap_x
		snap_spot_y = square_index_y * snap_y

		case :snap_lines
		when :snap_lines
			return_x, return_y = x, y
			return_x = square_index_x * snap_x if @always_snap or ((snap_spot_x - x).abs < SNAP_DISTANCE)
			return_y = square_index_y * snap_y if @always_snap or ((snap_spot_y - y).abs < SNAP_DISTANCE)
			return return_x, return_y

#		when :snap_intersections
#			if @always_snap or ((snap_spot_x - x).abs < SNAP_DISTANCE and (snap_spot_y - y).abs < SNAP_DISTANCE)
#				return square_index_x * snap_x, square_index_y * snap_y
#			else
#				return x, y
#			end
		end
	end

	def clear
	end

	def draw_grid(grid_lines)
		GL.Begin(GL::LINES)
			(-0.5).step(0.5, 1.0 / grid_lines) { |x| GL.Vertex(x, 0.5) ; GL.Vertex(x, -0.5) }
			(-0.5).step(0.5, 1.0 / grid_lines) { |y| GL.Vertex(0.5, y) ; GL.Vertex(-0.5, y) }
		GL.End
	end

	# horizontal and vertical lines marking the edges of the 1x1 square at the origin
	def draw_guides
		@guides_list ||= {}
		@guides_list[@zoom] ||= GL.RenderToList {
			GL.Begin(GL::LINES)
				GL.Vertex(-0.5, 0.5 / @zoom) ; GL.Vertex(-0.5, -0.5 / @zoom)
				GL.Vertex(0.5, 0.5 / @zoom) ; GL.Vertex(0.5, -0.5 / @zoom)
				GL.Vertex(-0.5 / @zoom, 0.5) ; GL.Vertex(0.5 / @zoom, 0.5)
				GL.Vertex(-0.5 / @zoom, -0.5) ; GL.Vertex(0.5 / @zoom, -0.5)
			GL.End
		}
		GL.CallList(@guides_list[@zoom])
	end

	# Location (one point in the center)
	def draw_location_handle(object)
		GL.Vertex(object.x, object.y)
	end

	def draw_handle(object)
		with_translation(object.x, object.y, object.z) {
			draw_handle_internal
		}
	end

	def draw_handle_internal
		#GL.Enable(GL::POINT_SMOOTH)

		# Each point is two GL points, the second smaller than the first
		GL.PointSize(GRAB_DISTANCE * 2)		# NOTE: OpenGL point sizes aren't affected by scaling
		GL.Color(0,0,0,1.0)
		GL.Begin(GL::POINTS)
			GL.Vertex(0.0, 0.0, 0.0)
		GL.End

		GL.PointSize((GRAB_DISTANCE * 2) - 2)
		GL.Color(1,0,0,1.0)
		GL.Begin(GL::POINTS)
			GL.Vertex(0.0, 0.0, 0.0)
		GL.End
	end

	def draw_handles(objects)
		objects.each { |object| draw_handle(object) }
	end
end
