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

class ActorEffectMirrorVertical < ActorEffect
	title				"Mirror Vertical"
	description "The top half of the actor is mirrored on the bottom side."

	categories :transform, :child_producer

	def render
		# Top
		with_clip_plane([0.0,  1.0, 0.0, 0.0]) {
			yield :child_index => 0, :total_children => 2
		}

		# Bottom
		with_clip_plane([0.0, -1.0, 0.0, 0.0]) {
			with_scale(1, -1) {
				yield :child_index => 1, :total_children => 2
			}
		}
	end
end
