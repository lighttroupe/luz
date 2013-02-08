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

class ActorEffectThemeScrubChildren < ActorEffect
	title				"Theme Scrub Children"
	description "Smoothly blends chosen theme onto children with chosen offset."

	categories :color, :child_consumer

	setting 'theme', :theme
	setting 'amount', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'offset', :float, :range => -1000..1000, :default => 0..1

	def render
		return yield if (theme.nil? or theme.empty? or amount == 0.0)

		index, scrub = (child_index + offset).divmod(1.0)
		style_a, style_b = theme.style(index), theme.style(index+1)
		style_a.using_amount(amount) {
			style_b.using_amount(scrub * amount) {
				yield
			}
		}
	end
end
