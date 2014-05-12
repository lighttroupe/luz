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

class VariableInputButtonPairSpring < VariableInput
	title				"Button Pair Spring"
	description "Activation rises when one button is pressed, lowers when a different button is pressed, and otherwise returns to chosen spring value."

	categories :button

	setting 'button_on', :button, :summary => '% on'
	setting :on_time, :timespan
	setting 'button_off', :button, :summary => '% off'
	setting :off_time, :timespan

	setting 'spring_value', :float, :simple => true, :range => 0.0..1.0, :default => 0.5..1.0

	def value
		return spring_value if first_frame?

		on = $engine.button_down?(button_on)
		off = $engine.button_down?(button_off)

		if on and off
			return (last_value)
		elsif on
			return 1.0 if on_time.instant?
			return (last_value + ($env[:frame_time_delta] / on_time.to_seconds))
		elsif off
			return 0.0 if off_time.instant?
			return (last_value - ($env[:frame_time_delta] / off_time.to_seconds))
		else
			delta = (spring_value - last_value)
			return spring_value if delta < 0.001

			return (last_value + delta * 0.9)
		end
	end
end
