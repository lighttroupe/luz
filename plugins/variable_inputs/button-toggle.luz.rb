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

class VariableInputButtonToggle < VariableInput
	title				"Button Toggle"
	description "Activation begins rising when button is pressed once, lowers when button is pressed a second time."

	setting 'button', :button, :summary => true
	setting 'on_time', :timespan, :summary => '% on'
	setting 'off_time', :timespan, :summary => '% off'

	def value
		if $engine.button_press_count(button).is_odd?
			return 1.0 if on_time.instant?
			return (last_value + ($env[:frame_time_delta] / on_time.to_seconds))
		else
			return 0.0 if off_time.instant?
			return (last_value - ($env[:frame_time_delta] / off_time.to_seconds))
		end
	end
end
