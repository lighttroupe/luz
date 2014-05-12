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

class EventInputButtonPair < EventInput
	title				"Button Pair"
	description "Activation turns on with one button press, turns off with a different button press."

	categories :button

	setting 'button_on', :button, :summary => true
	setting 'button_off', :button, :summary => true

	def value
		if $engine.button_pressed_this_frame?(button_on)
			true
		elsif $engine.button_pressed_this_frame?(button_off)
			false
		else
			last_value
		end
	end
end
