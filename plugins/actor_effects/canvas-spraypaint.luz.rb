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

class ActorEffectCanvasSpraypaint < ActorEffectCanvas
	title				"Canvas Spraypaint"
	description "Draws as dots randomly distributed within given radius."

	setting 'draw', :event

	setting 'x', :float, :range => -1.0..1.0, :default => 0.0..0.5
	setting 'y', :float, :range => -1.0..1.0, :default => 0.0..0.5

	setting 'radius', :float, :range => 0.005..1.0, :default => 0.005..1.0
#	setting 'curve_x', :curve
#	setting 'curve_y', :curve

	setting 'dot_width', :float, :range => 0.0..1.0, :default => 0.001..1.0
	setting 'dots_per_second', :integer, :range => 0..10000, :default => 200..10000

	def paint(c)
		return unless draw.now?

		centerx, centery = x, y
		d_w = dot_width

		n = (dots_per_second * $env[:frame_time_delta]).to_int

		c.set_operator(:over)
		n.times {
			angle = rand
			r = radius * rand
			half_r = r / 2.0

			spotx = centerx + (r * fuzzy_cosine(angle)) - half_r
			spoty = centery + (r * fuzzy_sine(angle)) - half_r

			c.move_to(spotx, spoty)
			c.arc(spotx,spoty, d_w, 0, 2*Math::PI)
			c.fill
		}
	end
end
