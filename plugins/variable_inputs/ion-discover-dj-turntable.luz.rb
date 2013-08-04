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

class VariableInputIonDiscoverDJTurntable < VariableInput
	title				"Ion Discover DJ Turntable"
	description "Reports rotational speed of turntable in a variety of ways."

	categories :device

	hint 'This plugin is written to handle the unique data patterns sent by a specific device, and may not be useful for other purposes.'

	setting('slider', :slider, {:summary => true})
	setting 'mode', :select, :options => [[:bidirectional, 'Bidirectional'], [:forward, 'Forward'], [:backward, 'Backward']], :default => :bidirectional

	def value
		case mode
		when :bidirectional
			if slider < 0.5
				0.5 + (slider / 0.2).clamp(0.0, 1.0) / 2.0
			else
				0.5 - ((1.0 - slider) / 0.2).clamp(0.0, 1.0) / 2.0
			end
		when :forward
			if slider < 0.5
				(slider / 0.2)
			else
				0.0
			end
		when :backward
			if slider < 0.5
				0.0
			else
				((1.0 - slider) / 0.2)
			end
		else
			raise NotImplementedError
		end
	end
end
