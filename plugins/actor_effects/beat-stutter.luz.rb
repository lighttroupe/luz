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

class ActorEffectBeatStutter < ActorEffect
	title				'Beat Stutter'
	description "Causes future effects that animate on the beat to appear to stutter."

	categories :special

	setting 'steps', :integer, :range => 0..64, :default => 1..2

	def render
		step_index, step_progress = $env[:beat_scale].divmod(1.0 / steps)
		with_beat_shift(-step_progress) {
			yield
		}
	end
end
