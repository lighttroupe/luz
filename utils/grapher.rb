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

require 'cairo_icon'

class Grapher < CairoIcon

	def self.pixbuf(window, width, height, fg_color, bg_color)
		super(window, width, height) { |cr|
			cr.translate(0.5, 0.5)
			cr.set_line_width(1.0)

			cr.set_source_rgba(bg_color[0], bg_color[1], bg_color[2], 1.0)
			cr.paint

			cr.set_source_rgba(*fg_color)

			start_x = 0.0
			start_y = yield 0.0
			cr.move_to(start_x, start_y)
			for x in 0...width
				y = yield x
				cr.line_to(x, height - y)
			end

			# All the way right
			cr.line_to(width, height - y)

			# Bottom right
			cr.line_to(width, height)

			# Bottom left
			cr.line_to(0.0, height)
			cr.fill_preserve

			# Add a slight outline
			cr.set_source_rgba(1.0, 1.0, 1.0, 0.5)
			cr.stroke

			# Outline with rectangle
	#	  cr.set_source_rgba(bg_color[0], bg_color[1], bg_color[2], 1.0)
	#	  cr.rectangle(0.0, 0.0, width - 0.5, height - 0.5)
	#	  cr.stroke
		}
	end
end
