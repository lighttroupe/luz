 ###############################################################################
 #  Copyright 2008 Ian McIntosh <ian@openanswers.org>
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

class EventInputRate < EventInput
	title				"Rate"
	description "Activates repeatedly with controllable rate."

	setting 'fastest', :timespan
	setting 'slowest', :timespan
	setting 'speed', :slider

	def value
		period = (speed * (fastest.to_seconds - slowest.to_seconds)) + slowest.to_seconds

		return time_since_last_activation >= period
	end
end
