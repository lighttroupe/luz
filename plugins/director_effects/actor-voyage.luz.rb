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

class DirectorEffectActorVoyage < DirectorEffect
	title				"Actor Voyage"
	description "Moves between selected actors using a percentage progress, showing at most two at a time."

	setting 'tag', :actors, :summary => 'tagged %'
	setting 'progress', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		tag.all { |actors|
			# integer number of actors
			count = actors.size

			# spot between 0.0 and eg. 7.0 for 6 actors
			spot = count * progress

			# the first actor
			index = spot.floor

			actor_lifetime = spot - index

			# New one comes in behind old one so draw it first
			with_enter_and_exit(actor_lifetime, 0.0) {
				actors[index].render!
			} if index < count

			# "Old" one, eg. the first one once we're showing 2 (when index == 1)
			with_enter_and_exit(1.0, actor_lifetime) {
				actors[index - 1].render!
			} if index > 0
		}
		yield
	end
end
