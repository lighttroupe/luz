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

class EventInputSliderSegmentedUp < EventInput
	title				"Slider Segmented Up"
	description "Activates each time slider crosses a boundary of one of a chosen number of segments going up."

	setting 'slider', :slider, :summary => true
	setting 'count', :integer, :range => 1..10000, :summary => '% segments'

	def value
		old_i = (count + 1).choose_index_by_fuzzy(slider_setting.last_value)
		new_i = (count + 1).choose_index_by_fuzzy(slider)
		delta = (new_i - old_i)

		(delta > 0) ? delta : 0
	end
end
