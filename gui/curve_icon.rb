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

require 'grapher'

class CurveIcon < Grapher
	def self.choose_color(curve)
		if curve.up?					# lower left to upper right (/)
			[0.35, 0.75, 0.25, 1.0]
		elsif curve.down?			# upper left to lower right (\)
			[0.80, 0.0, 0.0, 1.0]
		elsif curve.middle?		# starts and ends on 0.5 (~)
			[0.95, 0.50, 0.0, 1.0]
		elsif curve.looping?	# starts and ends on same value
			[0.8, 0.8, 0.0, 1.0]
		else									# anything else
			[0.5, 0.5, 0.8, 1.0]
		end
	end

	def self.pixbuf(window, curve, width, height)
		fg_color = choose_color(curve)
		bg_color = [0.0, 0.0, 0.0, 1.0]
		super(window, width, height, fg_color, bg_color) { |x|
			curve.value(x.to_f / width.to_f) * height
		}
	end
end
