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

class ActorEffectSlice < ActorEffect
	title				"Slice"
	description "Creates a chosen number of 'slices' of actor, each controllable separately as children."

	setting 'number', :integer, :range => 1..100, :default => 1..2
	setting 'angle', :float, :default => 0.0..1.0
	setting 'distribution', :curve

	def render
		return yield if number == 1

		width = ((2 * RADIUS) / number)
		one_over_number = (1.0 / number)		# dividing the curve X space

		with_roll(angle) {
			number.distribute_exclusive(-RADIUS..RADIUS) { |x, index|
				# sample the distribution curve at two points
				x1 = distribution.value(x + RADIUS) - RADIUS
				x2 = distribution.value(x + RADIUS + one_over_number) - RADIUS

				# swap them if they're out of order (curve sloping down)
				x1, x2 = x2, x1 if x1 > x2

				with_vertical_clip_plane_left_of(x1) {
					with_vertical_clip_plane_right_of(x2) {
						with_roll(-angle) {
							yield :child_index => index, :total_children => number
						}
					}
				}
			}
		}
	end
end
