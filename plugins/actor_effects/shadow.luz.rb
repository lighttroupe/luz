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

class ActorEffectShadow < ActorEffect
	title				"Shadow"
	description "Draws a shadow below the actor."

	setting 'alpha', :float, :range => 0.0..1.0, :default => 0.5..1.0
	setting 'size', :float, :range => 0.0..100.0, :default => 1.0..2.0
	setting 'angle', :float, :range => -1.0..1.0, :default => 0.0..1.0
	setting 'distance', :float, :range => -100.0..100.0, :default => 0.0..1.0

	def render
		with_angle_slide(angle, distance) {
			with_scale(size) {
				with_multiplied_alpha(alpha) {
					yield :child_index => 1, :total_children => 2
				}
			}
		}
		yield :child_index => 0, :total_children => 2 		# The normal actor
	end
end
