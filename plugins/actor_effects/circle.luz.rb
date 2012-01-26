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

class ActorCircle < ActorEffect
	title				"Circle"
	description "Draws actor many times in a circle, with configurable radius, start and stop angles."

	setting 'number', :integer, :range => 1..100, :default => 1..2
	setting 'radius', :float, :range => -100.0..100.0, :default => 0.0..1.0

	setting 'start_angle', :float, :default => 0.0..1.0
	setting 'stop_angle', :float, :default => 1.0..2.0

	setting 'distribution', :curve

	def render
		number.distribute_exclusive(start_angle..stop_angle) { |angle, index|
			angle = distribution.value(angle)
			with_roll(angle) {
				with_slide(radius) {
					yield :child_index => index, :total_children => number
				}
			}
		}
	end
end
