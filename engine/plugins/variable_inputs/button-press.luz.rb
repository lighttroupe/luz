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

class VariableInputButtonPress < VariableInput
	title				"Button Press"
	description "Activation rises with each press of a button, lowers constantly."

	categories :button

	setting 'button_on', :button
	setting 'number_on', :integer, :range => 1..100, :default => 1..100
	setting 'off_time', :timespan

	setting 'starting_value', :float, :simple => true, :default => 0.0..1.0

	def value
		return starting_value if first_frame?

		if $engine.button_pressed_this_frame?(button_on)
			return (last_value + (1.0 / number_on))
		elsif off_time.instant?
			return 0.0
		else
			return (last_value - ($env[:frame_time_delta] / off_time.to_seconds))
		end
	end
end
