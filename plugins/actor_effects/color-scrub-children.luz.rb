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

class ActorEffectColorScrubChildren < ActorEffect
	title				"Color Scrub Children"
	description ""

	setting 'color', :color
	setting 'progress', :float, :range => -1.0..2.0, :default => 0.0..1.0
	setting 'amount', :float,  :range => 0.0..1.0, :default => 1.0..1.0
	setting 'spread', :float, :range => 0.0..1.0, :default => 0.5..1.0

	def render
		child_progress = ((child_number-1).to_f / (total_children-1).to_f)
		delta = (child_progress - progress).abs
		# the bigger the delta, the less color application will occur
		# delta is 0.0..1.0
		delta /= (spread * 2.0)
		fade_amount = (amount - delta).clamp(0.0, 1.0)
		with_color(current_color.fade_to(fade_amount, color)) {
			yield
		}
	end
end
