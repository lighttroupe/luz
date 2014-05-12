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

class ActorEffectActorAttach < ActorEffect
	title				'Actor Attach'
	description "Attach another actor above or below this one, at a chosen offset, angle, and distance."

	categories :special

	hint "This can be used to build robots, attaching arm to torso, etc."

	setting 'actor', :actor, :summary => true
	setting 'position', :select, :options => [[:below, 'Below'], [:above, 'Above']], :default => :above		# above = more likely to be visible

	setting 'offset_x', :float, :default => 0.0..1.0
	setting 'offset_y', :float, :default => 0.0..1.0

	setting 'angle', :float, :default => 0.0..1.0
	setting 'distance', :float, :default => 0.0..1.0

	setting 'scale', :float, :default => 1.0..2.0

	def render
		yield if position == :above

		actor.one { |a|
			with_translation(offset_x, offset_y) {
				with_roll(angle) {
					with_slide(distance) {
						with_scale(scale) {
							a.render!
						}
					}
				}
			}
		}

		yield if position == :below
	end
end
