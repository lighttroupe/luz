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

require 'cairo'

class ColorPixbuf
	CHECKER_SIZE = 8
	CHECKER_COLOR1 = [0.74, 0.74, 0.74, 1.0]
	CHECKER_COLOR2 = [0.5, 0.5, 0.5, 1.0]

	def self.pixmap(window, width, height, color)
		pixmap = Gdk::Pixmap.new(window, width, height, depth=-1)		# NOTE: -1 means "get it from the window" http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gdk%3A%3APixmap
		cr = pixmap.create_cairo_context
		self.draw(cr, width, height, color)
	  return pixmap
	end

	def self.pixbuf(window, width, height, color)
		return Gdk::Pixbuf.from_drawable(window.colormap, self.pixmap(window, width, height, color), src_x = 0, src_y = 0, width, height)
	end

private

	def self.draw(cr, width, height, color)
	  cr.set_source_rgba(*CHECKER_COLOR1)
	  cr.paint

	  cr.set_source_rgba(*CHECKER_COLOR2)
	  0.step(width, CHECKER_SIZE) { |x|
		  0.step(height, CHECKER_SIZE) { |y|
	  		cr.rectangle(x, y, CHECKER_SIZE, CHECKER_SIZE) if ((x + y) / CHECKER_SIZE).is_odd?
	  	}
	  }
	  cr.fill	# draw all rectangles at once

	  cr.set_source_rgba(*color.cairo_color)
	  cr.paint

		# Outline with rectangle
	  cr.set_source_rgba(0.0, 0.0, 0.0, 1.0)
	  cr.set_line_width(1.0)
	  cr.rectangle(0.5, 0.5, width - 1.0, height - 1.0)
	  cr.stroke
	end
end
