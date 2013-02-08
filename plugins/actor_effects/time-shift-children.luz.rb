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

class ActorEffectTimeShiftChildren < ActorEffect
	title				'Time Shift Children'
	description "Causes children to render as if each successive child were more in the past."

	hint "Place this after an effect that creates children, and before one or more effects that animate on time."

	categories :special, :child_consumer

	setting 'time_per_child', :timespan
	setting 'amount', :float, :default => 0.0..1.0

	def render
		with_time_shift(amount * -(time_per_child.to_seconds) * child_index) {
			yield
		}
	end
end
