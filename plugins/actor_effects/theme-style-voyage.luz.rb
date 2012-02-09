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

class ActorEffectThemeStyleVoyage < ActorEffect
	title				"Theme Voyage"
	description "Fades gradually between the styles of chosen theme."

	setting 'theme', :theme
	setting 'progress', :float, :default => 0.0..1.0

	def render
		return yield unless theme

		count = theme.effects.size		# TODO: clean this up
		return yield if count == 0

		# spot between 0.0 and eg. 7.0 for 7 actors
		spot = (count) * progress

		# the first actor
		index = spot.floor

		fade_amount = spot - index

		theme.using_style(index) {
			theme.using_style_amount((index+1) % count, fade_amount) {
				yield
			}
		}
	end
end
