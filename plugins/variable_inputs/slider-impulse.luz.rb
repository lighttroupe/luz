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

class VariableInputSliderImpulse < VariableInput
	title				"Slider Impulse"
	description "Treats slider input value as an upward impulse. The value falls back down to 0% according to a chosen gravity."

	hint "Only registers a second impulse after the input value has returned to 0. Works well with MIDI drums which send the velocity of impact, then immediately send a 0 value."

	setting 'slider', :slider, :summary => true
	setting 'gravity_per_second', :float, :range => 0.0..5.0

	setting 'velocity_multiplier', :float, :range => 0.0..1.0, :default => 1.0..0.0

	def value
		@velocity ||= 0.0

		# add to velocity
		if slider > 0.0 and slider_setting.last_value == 0.0

			# stop all downward velocity on a hit (is this right?)
			#@velocity = 0.0 if @velocity < 0.0

			@velocity += (slider * velocity_multiplier)
		end

		# move output value by velocity
		v = (last_value + (@velocity * $env[:frame_time_delta])).clamp(0.0, 1.0)

		# hit the ceiling?
		if v == 1.0 and @velocity > 0.0
			@velocity = 0.0

		# hit the floor?
		elsif v == 0.0 and @velocity < 0.0
			@velocity = 0.0

		else
			# floating...
			@velocity -= (gravity_per_second * $env[:frame_time_delta]) if v > 0.0
		end

		return v
	end
end
