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

class ActorEffectLine < ActorEffect
	title				"Line"
	description "Draws actor many times in a line."

	setting 'number', :integer, :range => 1..100, :default => 1..2, :summary => true
	setting 'angle', :float, :range => -1.0..1.0, :default => 0.0..1.0
	setting 'distance', :float, :range => -100.0..100.0, :default => 1.0..2.0

	def render
		with_roll(angle) {
			for i in 0...number
				with_slide(distance * i) {
					with_roll(-angle) {
						yield :child_index => i, :total_children => number
					}
				}
			end
		}
	end
end
