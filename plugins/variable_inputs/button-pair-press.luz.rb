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

class VariableInputButtonPairPress < VariableInput
	title				"Button Pair Press"
	description "Activation rises with each press of one button, lowers with each press of a different button."

	setting 'button_on', :button, :summary => '% on'
	setting 'number_on', :integer, :range => 1..100, :default => 1..100
	setting 'button_off', :button, :summary => '% off'
	setting 'number_off', :integer, :range => 1..100, :default => 1..100

	setting 'starting_value', :float, :simple => true, :default => 0.0..1.0

	def value
		return starting_value if first_frame?

		new_value = last_value
		new_value += (1.0 / number_on) if $engine.button_pressed_this_frame?(button_on)
		new_value -= (1.0 / number_off) if $engine.button_pressed_this_frame?(button_off)
		return new_value
	end
end
