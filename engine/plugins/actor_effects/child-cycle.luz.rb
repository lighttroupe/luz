 ###############################################################################
 #  Copyright 2013 Ian McIntosh <ian@openanswers.org>
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

class ActorEffectChildCycle < ActorEffect
	require 'cycle-logic'
	include CycleLogic

	title				"Child Cycle"
	description "Causes children to enter and exit, where at most two are visible at a time."

	categories :child_consumer

	setting 'forwards', :event, :summary => '% forward'
	setting 'backwards', :event, :summary => '% backward'
	setting 'crossfade_time', :timespan, :summary => true

	hint "Future effects should respond to enter and exit."

	def tick
		@current_spot = cycle_update(@current_spot, (forwards.count - backwards.count), crossfade_time)
	end

	def render
		low_index = @current_spot.floor % total_children
		high_index = (low_index + 1) % total_children
		progress = (@current_spot - @current_spot.floor)
		if (child_index == low_index) && (progress != 1.0)
			with_enter_and_exit(1.0, progress) {
				yield
			}
		end

		if (child_index == high_index) && (progress != 0.0)
			with_enter_and_exit(progress, 0.0) {
				yield
			}
		end
	end
end
