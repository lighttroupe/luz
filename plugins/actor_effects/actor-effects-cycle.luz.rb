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

class ActorEffectActorEffectsCycle < ActorEffect
	require 'cycle-logic'
	include CycleLogic

	title				'Actor Effects Cycle'
	description ""

	setting 'actors', :actors, :summary => 'tagged %'

	setting 'forwards', :event, :summary => '% forward'
	setting 'backwards', :event, :summary => '% backward'

	setting 'crossfade_time', :timespan, :summary => true

	def render
		@current_spot = cycle_update(@current_spot, (forwards.count - backwards.count), crossfade_time)

		low_index = @current_spot.floor
		first, second, progress = actors.one(low_index), actors.one(low_index+1), (@current_spot - low_index)
		use_first = (first and (progress != 1.0))
		use_second = (second and (progress != 0.0))
		if use_first
			with_enter_and_exit(1.0, progress) {
				first.render_recursive {
					if use_second
						with_enter_and_exit(progress, 0.0) {
							second.render_recursive { yield }
						} 
					else
						yield
					end
				}
			}
		elsif use_second
			with_enter_and_exit(progress, 0.0) {
				second.render_recursive { yield }
			}
		end 
	end
end
