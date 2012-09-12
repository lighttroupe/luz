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

class ThemeIcon < CairoIcon

	def self.pixbuf(window, theme, width, height)
		super(window, width, height) { |cr|
			if theme.effects.size > 8
				num_rows = 4
			else
				num_rows = 2
			end
			height_per_row = (height / num_rows)
			num_per_row = (width / height_per_row)	# height_per_row is also width per style, since we're drawing squares

			# Icon's background is the theme's background color
		  cr.set_source_rgb(*theme.background_color.cairo_color_without_alpha)
		  cr.paint

			# Remaining colors go left to right in successive rows
			theme.effects.each_with_index { |style, index|
				row_index, column_index = index.divmod(num_per_row)
				break if row_index >= num_rows		# All done?

				cr.set_source_rgba(style.color.cairo_color)
				cr.rectangle((column_index * height_per_row) + 1, (row_index * height_per_row) + 1, height_per_row - 2, height_per_row - 2)
				cr.fill
			}
		}
	end
end
