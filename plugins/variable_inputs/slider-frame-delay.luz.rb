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

class VariableInputSliderFrameDelay < VariableInput
	title				"Slider Frame Delay"
	description "Saves slider values, and replays them a chosen number of frames in the future."

	setting 'slider', :slider, :summary => true
	setting 'frames', :integer, :range => 0..100, :default => 30..60, :summary => '% frames'

	def value
		@samples ||= Array.new

		# add one new value
		@samples << slider

		# save oldest value
		v = @samples.first

		# remove old values (more than one, because 'frames' can change on us)
		to_remove = @samples.size - (frames)		# this will be 1 most of the time
		to_remove.times { @samples.shift }

		return v
	end
end
