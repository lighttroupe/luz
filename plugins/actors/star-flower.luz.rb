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

class ActorStarFlower < ActorShape
	title				"Star Flower"
	description "A pointy or rounded star shape with controllable number of arms and inner radius."

	setting 'arms', :integer, :range => 2..100, :default => 5..100, :breaks_cache => true
	setting 'radius', :float, :range => -2.0..2.0, :default => 0.2..1.0, :breaks_cache => true
	setting 'detail', :integer, :range => 1..100, :default => 50..100, :breaks_cache => true		# Points between arms

	cache_rendering

	def shape
		yield :shape => MyGL.VariableCircle(arms, detail + 1) {
				|fuzzy| (radius * RADIUS) + (fuzzy_cosine(fuzzy) * (RADIUS - (radius * RADIUS)))
			}
	end
end
