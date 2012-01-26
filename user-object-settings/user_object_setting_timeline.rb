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

require 'user_object_setting', 'drawing'

#ControlPoint = Struct.new(:x, :y, :type, :ax, :ay, :bx, :by)

class ControlPoint
	attr_accessor :x, :y, :type, :ax, :ay, :bx, :by

	def initialize(x, y, type=nil, ax=0.0, ay=0.0, bx=0.0, by=0.0)
		@x, @y, @type, @ax, @ay, @bx, @by = x, y, type, ax, ay, bx, by
	end

	def to_yaml_properties
		['@x', '@y', '@type', '@ax', '@ay', '@bx', '@by']
	end
end

if defined? Gtk
	require 'gtk_gl_drawing_area'

	class TimelineWidget < Gtk::DrawingArea
		BACKGROUND_COLOR = [0.0, 0.0, 0.0, 1.0]
		LINE_COLOR = [0.7, 1.0, 0.7, 1.0]
		LINE_FILL_COLOR = [0.6, 1.0, 0.6, 0.6]
		CONTROL_POINT_COLOR = [1.0, 0.3, 0.3, 1.0]
		CONTROL_POINT_RADIUS = 5.0
		GUIDE_LINE_COLOR = [1.0, 1.0, 1.0, 0.1]
		BORDER_COLOR_FOCUSED = [1.0, 1.0, 1.0, 0.5]
		BORDER_COLOR_UNFOCUSED = [1.0, 1.0, 1.0, 0.2]
		PROGRESS_BAR_COLOR = [1.0, 1.0, 0.0, 1.0]
		DRAG_TO_DELETE_MARGIN = 0.15

		include Drawing

		callback :change

		attr_accessor :points

		def initialize(timeline)
			@timeline = timeline

			super()

			self.can_focus = true

			on_expose { draw }
			on_click { |x, y| handle_click(x, allocation.height - y) }
			on_mouse_motion { |x, y| handle_motion(x, allocation.height - y) }
			on_primary_mouse_button_up { @grab_index = nil }

			on_key_press(Gdk::Keyval::GDK_space) { create_point_at_current_progress }

			@view_size = 1.0

			on_scroll_wheel_up { zoom_in }
			on_scroll_wheel_down { zoom_out }
		end

		def zoom_in
			@view_size = (@view_size * 0.9).clamp(0.01, 1.0)
			queue_draw
		end

		def zoom_out
			@view_size = (@view_size * 1.1).clamp(0.0, 1.0)
			queue_draw
		end

		def draw
			visible_range = calculate_visible_range

			@cr = window.create_cairo_context		# NOTE: Carl Worth says we can reuse a context, but only one for each expose event.  TODO: should we be doing drawing using expose events?

			# First set it to (0.0,0.0) in bottom right corner
			@cr.scale 1.0, -1.0
			@cr.translate 0.0, -height

			@cr.set_source_rgba(*BACKGROUND_COLOR)
			@cr.paint

			draw_guide_lines
			draw_line_filled
			draw_line
			draw_points

			draw_border(visible_range)

			@cr.set_source_rgba(*PROGRESS_BAR_COLOR)
			@cr.set_line_width(1.0)
			draw_progress_indicator(@timeline.last_value_request)
		end

		def draw_update
			queue_draw unless @last_progress == @timeline.last_value_request
		end

		def draw_guide_lines
			@cr.set_line_width(1.0)
			@cr.set_source_rgba(*GUIDE_LINE_COLOR)

			# horizontal lines
			@cr.move_to(0.0, 0.75 * height) ; @cr.line_to(width, 0.75 * height)
			@cr.move_to(0.0, 0.5 * height) ; @cr.line_to(width, 0.5 * height)
			@cr.move_to(0.0, 0.25 * height) ; @cr.line_to(width, 0.25 * height)
			@cr.stroke
		end

=begin
		def draw_line
			@timeline.points.each_with_index { |point, index|
				x, y = point.x * width, point.y * height
				if index == 0
					@cr.move_to(x, y)
				else
					@cr.line_to(x, y)
				end
			}
			@cr.stroke
		end
=end

		def visible_index_range
			visible_range = calculate_visible_range
			index_range = visible_range_to_index_range(visible_range)

			first_index = index_range.first
			first_index -= 1 unless first_index == 0

			last_index = index_range.last
			last_index += 1 unless last_index == @timeline.points.size-1

			return (first_index..last_index)
		end

		def draw_line
			@cr.set_line_width(2.0)
			@cr.set_source_rgba(*LINE_COLOR)

			points = @timeline.points
			is_first = true

			for i in visible_index_range
				point = points[i]

#				x, y = point.x * width, point.y * height
				pixel_x, pixel_y = internal_to_pixel(point.x, point.y)

				if is_first
					@cr.move_to(pixel_x, pixel_y)
					is_first = false
				else
					@cr.line_to(pixel_x, pixel_y)
				end
			end

			@cr.stroke
		end

		def draw_line_filled
			@cr.set_source_rgba(*LINE_FILL_COLOR)

			points = @timeline.points
			@cr.move_to(0.0, 0.0)
			for i in visible_index_range
				point = points[i]
				pixel_x, pixel_y = internal_to_pixel(point.x, point.y)
				@cr.line_to(pixel_x, pixel_y)
			end
			@cr.line_to(pixel_x, 0.0)
			@cr.line_to(0.0, 0.0)
			@cr.fill
		end

		def draw_points
			points = @timeline.points
			for i in visible_index_range
				point = points[i]
				pixel_x, pixel_y = internal_to_pixel(point.x, point.y)
				@cr.move_to(pixel_x, pixel_y)
				@cr.arc(pixel_x, pixel_y, CONTROL_POINT_RADIUS, 0.0, 2*Math::PI)
			end
			@cr.set_source_rgba(*BACKGROUND_COLOR)
			@cr.fill

			for i in visible_index_range
				point = points[i]
				pixel_x, pixel_y = internal_to_pixel(point.x, point.y)
				@cr.move_to(pixel_x, pixel_y)
				@cr.arc(pixel_x, pixel_y, CONTROL_POINT_RADIUS, 0.0, 2*Math::PI)
			end
			@cr.set_source_rgba(*LINE_COLOR)
			@cr.stroke
		end

		def draw_progress_indicator(progress)
			return unless progress

			y = @timeline.value_at_time(progress)

			pixel_x, pixel_y = internal_to_pixel(progress, y)

			# vertical line indicating current 'x' value
			@cr.move_to(pixel_x, height)
			@cr.line_to(pixel_x, 0.0)
			@cr.move_to(pixel_x, pixel_y)
			@cr.line_to(pixel_x, 0.0)
			@cr.stroke

			# dot indicating current 'y' value
			@cr.move_to(pixel_x, pixel_y)
			@cr.arc(pixel_x, pixel_y, CONTROL_POINT_RADIUS / 2.0, 0.0, 2*Math::PI)
			@cr.fill

			@last_progress = progress
		end

		def handle_click(x, y)
			grab_focus

			# try to click on a point
			index = match_point(x, y)

			if index
				# grabbed a point
				@grab_index = index
				set_cursor(:grab_point)
			elsif (index = match_line(x, y))
				# clicked on a line
				x, y = pixel_to_internal(x, y)
				@timeline.points.insert(index+1, ControlPoint.new(x, y))
				@grab_index = index+1
				set_cursor(:grab_point)
				queue_draw
				change_notify
			end
		end

		def create_point_at_current_progress
			x = @timeline.last_value_request
			point_index = @timeline.points.bsearch_lower_boundary { |p| p.x <=> x }
			x_delta = (x - @timeline.points[point_index].x).abs
			y = @timeline.value_at_time(x)
			@timeline.points.insert(point_index, ControlPoint.new(x, y))
		end

		def handle_motion(x, y)
			if @grab_index
				handle_drag(x, y)
			else
				# set cursor based on hit testing
				if match_point(x, y)
					set_cursor(:hover_point)
				elsif match_line(x, y)
					set_cursor(:hover_line)
				else
					set_cursor(nil)
				end
			end
		end

		def draw_border(visible_range)
			@cr.set_line_width(3.0)
			if has_focus?
				@cr.set_source_rgba(*BORDER_COLOR_FOCUSED)
			else
				@cr.set_source_rgba(*BORDER_COLOR_UNFOCUSED)
			end
			@cr.move_to(0, 0) ; @cr.line_to(width, 0)
			@cr.move_to(0, height) ; @cr.line_to(width, height)

			@cr.move_to(0, 0) ; @cr.line_to(0, height) if visible_range.first == 0.0
			@cr.move_to(width, 0) ; @cr.line_to(width, height) if visible_range.last == 1.0
			@cr.stroke
		end

		def handle_drag(x, y)
			p = @timeline.points[@grab_index]

			p.x, p.y = pixel_to_internal(x, y)

			# Snap X value of first and last points
			if @grab_index == 0
				p.x = 0.0
			elsif @grab_index == @timeline.points.size - 1
				p.x = 1.0
			else
				# can't go left of previous point
				p.x = [p.x, @timeline.points[@grab_index - 1].x].max

				# can't go right of next point
				p.x = [p.x, @timeline.points[@grab_index + 1].x].min

				# delete point if user drags it well outside border
				if p.y < (0.0 - DRAG_TO_DELETE_MARGIN) or p.y > (1.0 + DRAG_TO_DELETE_MARGIN)
					# note that the first and last points can't be deleted
					@timeline.points.delete_at(@grab_index)
					@grab_index = nil
					queue_draw
					change_notify
					return
				end
			end
			p.y = p.y.clamp(0.0, 1.0)
			@timeline.points[@grab_index].x = p.x
			@timeline.points[@grab_index].y = p.y
			queue_draw
			change_notify
		end

		# take x,y in pixels and convert to 0.0,1.0
		def pixel_to_internal(x, y)
			#
			x, y = x / width, y / height
			visible_range = calculate_visible_range

			# scale/translate x based on zoom/scroll
			x = visible_range.first + (x * (visible_range.last - visible_range.first))

			return [x, y]
		end

		def internal_to_pixel(x, y)
			visible_range = calculate_visible_range
			x = (x - visible_range.first) / (visible_range.last - visible_range.first)
			return [x * width, y * height]
		end


		def calculate_visible_range
			return 0.0..1.0 if @view_size == 1.0

			center = @timeline.last_value_request

			range = (center - @view_size/2.0)..(center + @view_size/2.0)

			if range.first < 0.0
				range = (0.0)..(@view_size)
			elsif range.last > 1.0
				range = (1.0 - (@view_size))..(1.0)
			end

			range
		end

		def visible_range_to_index_range(visible_range)
			range = @timeline.points.bsearch_range { |p| (p.x < visible_range.first) ? -1.0 : ((p.x > visible_range.last) ? 1.0 : 0.0) }
			range = (range.first-1..range.last) unless range.first == 0
			range = (range.first..range.last-1) if range.last == @timeline.points.size
			range
		end

		#
		# does x,y fall on a point?
		#
		def match_point(pixel_x, pixel_y)
			@timeline.points.each_with_index { |point, index|
				point_pixel_x, point_pixel_y = internal_to_pixel(point.x, point.y)

				if point_pixel_x and ((point_pixel_x - pixel_x).squared + (point_pixel_y - pixel_y).squared) < (CONTROL_POINT_RADIUS * 1.3)**2
					return index
				end
			}
			return nil
		end

		#
		# does x,y fall on a line?
		#
		def match_line(x, y)
			x, y = pixel_to_internal(x, y)

			for index in (0...@timeline.points.size-1)
				ax = @timeline.points[index].x
				ay = @timeline.points[index].y
				bx = @timeline.points[index+1].x
				by = @timeline.points[index+1].y

				# exclude hits outside line segment
				next if (x < ax) or (x > bx) or (y > ay and y > by) or (y < ay and y < by)

				a = x - ax
	#			next unless a > 0.0		# exclude

				b = y - ay
	#			next unless b > 0.0

				c = bx - ax
				d = by - ay

				dist = (a * d - c * b).abs / (c * c + d * d).square_root

				# radius is half-width of the line
				return index if (dist <= 0.03) #and (position.distance_to(point) < (length / 2.0))
			end
			nil
		end

		def set_cursor(type)
			cursor = {:hover_point => Gdk::Cursor::HAND2, :hover_line => Gdk::Cursor::PLUS, :grab_point => Gdk::Cursor::FLEUR}[type] || Gdk::Cursor::ARROW
			window.set_cursor(Gdk::Cursor.new(cursor))
		end
	end
end

require 'bsearch'

class UserObjectSettingTimeline < UserObjectSetting
	attr_accessor :points
	attr_reader :last_value_request

	def to_yaml_properties
		['@points'] + super
	end

	def after_load
		set_default_instance_variables(:points => [ControlPoint.new(0.0, 0.0), ControlPoint.new(1.0, 1.0)])
		super
	end

	def widget
		timeline = TimelineWidget.new(self).show

#		timeline.points = @points
#		timeline.on_change { @points = timeline.points }

#		timeline.width_request = 200
		timeline.height_request = 200

		return timeline
	end

	def widget_expands?
		true
	end

	def immediate_value
		self
	end

	def value_at_time(x)
		@last_value_request = x

		point_index = @points.bsearch_lower_boundary { |p| p.x <=> x }
		if point_index
			point_index -= 1 if point_index > 0

			line_length = (@points[point_index+1].x - @points[point_index].x)
			return @points[point_index+1].y if line_length <= 0.0

			distance = (x - @points[point_index].x)

			progress = distance / line_length
			return @points[point_index].y + progress * (@points[point_index+1].y - @points[point_index].y)
		else
			0.0
		end
	end
end
