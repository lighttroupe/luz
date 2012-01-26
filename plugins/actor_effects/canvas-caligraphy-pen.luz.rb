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

class ActorEffectCanvasCaligraphyPen < ActorEffectCanvas
	title				"Canvas Caligraphy Pen"
	description "Draws with a flat-tipped pen."

	setting 'draw', :event
	setting 'width', :float, :range => 0.0..2.0, :default => 0.05..2.0
	setting 'x', :float, :range => -1.0..1.0, :default => -0.5..0.5
	setting 'y', :float, :range => -1.0..1.0, :default => -0.5..0.5

	def paint(c)
		return unless draw.now? or draw.previous_frame?

		# Decide widths of the line at previous and current point
		if draw.now?
			w2_prev = width_setting.last_value / 2.0
			w2 = width / 2.0
		elsif draw.previous_frame?
			w2_prev = width_setting.last_value / 2.0
			w2 = 0.0
		end

		c.move_to(x_setting.last_value, y_setting.last_value - w2_prev)
		c.line_to(x, y - w2)
		c.line_to(x, y + w2)
		c.line_to(x_setting.last_value, y_setting.last_value + w2_prev)
		c.close_path
		c.fill
	end
end
