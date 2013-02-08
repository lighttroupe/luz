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

class ActorEffectChildSelector < ActorEffect
	title				"Child Selector"
	description "Forcibly sets the internal 'child number' based on the activation count of a chosen event."

	categories :child_consumer

	hint "Future effects can be filtered based on the child number."

	setting 'event', :event
	setting 'count', :integer, :range => 1..100, :default => 2..3

	def render
		# This is a real hack of the child numbering system. :) -Ian
		yield :child_index => (event_setting.count % count), :total_children => count
	end
end
