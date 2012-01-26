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

class ActorEffectRadialBlurRepeater < ActorEffect
	title				"Radial Blur Repeater"
	description "A blur effect created by repeating the actor multiple times, each larger than the last."

	setting 'amount', :float, :range => 0.0..100.0, :default => 0.0..0.5
	setting 'number', :integer, :range => 1..1000, :default => 0..2

	def render
		return yield if number == 1 or amount == 0.0

		with_pixel_combine_function(:brighten) {
			with_multiplied_alpha(1.0 / number) {
				number.times { |n|
					with_scale(1.0 + (amount * n)) {
						yield :child_index => n, :total_children => number
					}
				}
			}
		}
	end
end
