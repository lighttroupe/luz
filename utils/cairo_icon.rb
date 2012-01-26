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

require 'cairo'

class CairoIcon

	# Create a pixbuf using the supplied proc to do the drawing
	def self.pixbuf(window, width, height, &proc)
		return Gdk::Pixbuf.from_drawable(window.colormap, self.pixmap(window, width, height, &proc), src_x = 0, src_y = 0, width, height)
	end

	# Create a pixmap using the supplied proc to do the drawing
	def self.pixmap(window, width, height, &proc)
		pixmap = Gdk::Pixmap.new(window, width, height, window.depth)
		proc.call(pixmap.create_cairo_context)
	  return pixmap
	end
end
