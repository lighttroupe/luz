 ###############################################################################
 #  Copyright 2008 Ian McIntosh <ian@openanswers.org>
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

class ActorEffectCanvasPen < ActorEffectCanvas
	title				"Canvas Pen"
	description "Draws as lines of varying width."

	setting 'draw', :event, :summary => true

	setting 'x', :float, :range => -1.0..1.0, :default => 0.0..0.5
	setting 'y', :float, :range => -1.0..1.0, :default => 0.0..0.5
	setting 'width', :float, :range => 0.0..2.0, :default => 0.05..2.0

	def paint(c)
		return unless draw.now?

		w1 = width_setting.last_value
		w2 = width
		return if w1 == 0.0 and w2 == 0.0

		x1 = x_setting.last_value
		x2 = x

		y1 = y_setting.last_value
		y2 = y

		delta_distance = ((x2 - x1).squared + (y2 - y1).squared).square_root

		c.save
		c.set_operator(:over)
		c.set_line_width(0.002)

		if delta_distance > 0.0
			c.move_to(x1, y1)
			c.arc(x1,y1,w1/2.0,0,2*Math::PI)
			c.fill
			#c.stroke

			delta_x = x2 - x1
			delta_y = y2 - y1

			# to Unit vectors
			delta_x /= delta_distance
			delta_y /= delta_distance

			c.move_to(x1 - delta_y * (w1 / 2.0), y1 + delta_x * (w1 / 2.0))
			c.line_to(x2 - delta_y * (w2 / 2.0), y2 + delta_x * (w2 / 2.0))
			c.line_to(x2 + delta_y * (w2 / 2.0), y2 - delta_x * (w2 / 2.0))
			c.line_to(x1 + delta_y * (w1 / 2.0), y1 - delta_x * (w1 / 2.0))
			c.line_to(x1 - delta_y * (w1 / 2.0), y1 + delta_x * (w1 / 2.0))
			c.fill
			#c.stroke

			#@last_delta_x, @last_delta_y = delta_x, delta_y
		end

		c.move_to(x2, y2)
		c.arc(x2,y2,w2/2.0 ,0,2*Math::PI)
		c.fill
		#c.stroke

		c.restore
	end
end
