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

class ActorEffectHideWedge < ActorEffect
	title				"Hide Wedge"
	description "Hides a wedge of the actor."

	categories :transform

	setting 'start_angle', :float, :default => 0.0..1.0
	setting 'wedge_size', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		# Draw "left" half
		with_clip_plane_right_of_angle(start_angle) {
			with_clip_plane_right_of_angle(start_angle - wedge_size / 2) {
				yield
			}
		}

		# Draw "right" half
		with_clip_plane_left_of_angle(start_angle) {
			with_clip_plane_left_of_angle(start_angle + wedge_size / 2) {
				yield
			}
		}
	end
end
