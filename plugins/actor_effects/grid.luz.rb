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

class ActorEffectGrid < ActorEffect
	title				"Grid"
	description	"Draws actor many times in a grid pattern, left to right, top to bottom."

	setting 'offset', :float, :range => -100.0..100.0, :default => 1.0..2.0
	setting 'number_x', :integer, :range => 0..100, :default => 1..2, :summary => true
	setting 'number_y', :integer, :range => 0..100, :default => 1..2, :summary => true

	def render
		total_children = number_x * number_y

		with_translation(-(number_x * offset * 0.5) + 0.5 + (offset - 1.0) / 2.0,  -(number_y * offset * 0.5) + 0.5 + (offset - 1.0) / 2.0) {
			for y in (0...number_y)
				for x in (0...number_x)
					with_translation((x * offset), (((number_y - y) - 1) * offset)) {
						yield :child_index => x + (y * number_x), :total_children => total_children
					}
				end
			end
		}
	end
end
