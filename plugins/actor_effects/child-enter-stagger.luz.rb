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

class ActorEffectChildEnterStagger < ActorEffect
	title				"Child Enter Stagger"
	description "Causes children to enter consecutively, instead of concurently."

	hint "Use after an effect that creates children (eg. Line) and before one or more plugins that use Enter."

	def render
		# spot between 0.0 and eg. 7.0 for 6 actors
		spot = total_children * $env[:enter]

		# the active actor
		index = spot.floor

		if child_index == index
			with_env(:enter, spot - index) { yield }
		elsif child_index > index
			with_env(:enter, 0.0) { yield }
		else
			with_env(:enter, 1.0) { yield }
		end
	end
end
