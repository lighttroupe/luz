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

class ProjectEffectTimeBump < ProjectEffect
	title				'Time Bump'
	description "Causes all time-based animations to jump forward or backward in time."

	setting 'amount', :timespan

	setting 'bump_forward', :event
	setting 'bump_backward', :event

	def pretick
		$engine.add_to_engine_time(amount.to_seconds) if bump_forward.on_this_frame?
		$engine.add_to_engine_time(-amount.to_seconds) if bump_backward.on_this_frame?
	end
end
