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

class ActorRectangleMesh < ActorShape
	title				"Rectangle Mesh"
	description "A rectangle with additional vertices, suitable for use with effects that warp vertices."

	cache_rendering

	setting 'density', :integer, :range => 2..100, :default => 5..100, :breaks_cache => true

	def shape
		shape = []
		d = density
		for y in (-d..d-1)
			for x in (-d..d)
				shape << x.to_f / (d * 2.0)
				shape << y.to_f / (d * 2.0)

				shape << (x).to_f / (d * 2.0)
				shape << (y+1).to_f / (d * 2.0)
			end
		end

		yield :type => :triangle_strip, :shape => shape
	end
end
