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

class VariableInputSliderSeekUpDown < VariableInput
	title				"Slider Seek Up Down"
	description "Output value moves towards the input value, at different speeds while moving up and down."

	setting 'slider', :slider, :summary => true
	setting 'seek_time_up', :timespan, :summary => '% up'
	setting 'seek_time_down', :timespan, :summary => '% down'

	def value
		from = last_value
		to = slider

		if from != to
			time = (to > from) ? seek_time_up.to_seconds : seek_time_down.to_seconds
			return (from + (($env[:time_delta] / time).clamp(0.0, 1.0) * (to - from)))
		else
			return to
		end
	end
end
