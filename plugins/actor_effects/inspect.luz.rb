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

class ActorEffectInspect < ActorEffect
	title				'Inspect'
	description "Zoom in and pan on an actor while keeping it entirely on screen."

	setting 'zoom', :float, :default => 1.0..2.0

	setting 'x', :float, :range => -0.5..0.5, :default => 0.0..0.5
	setting 'y', :float, :range => -0.5..0.5, :default => 0.0..0.5

	def render
		# When zoom is 1.0, we can't translate at all.
		# When zoom is 2.0, we can translate exactly 0.5.
		# When zoom is 3.0, we must translate 1.0 to reach the border, etc.
		with_translation(-x * (zoom - 1.0), -y * (zoom - 1.0)) {		# NOTE: negate x and y because they mean "go" and not "move"
			with_scale(zoom) {
				yield
			}
		}
	end
end
