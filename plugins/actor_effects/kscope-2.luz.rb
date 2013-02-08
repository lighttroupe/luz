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

class ActorEffectKScope2 < ActorEffect
	title				"KScope2"
	description "Kaleidescope effect."

	categories :transform, :child_producer

	setting 'folds', :float, :range => 1.0..100.0, :default => 1.0..2.0

	def render
		return yield if folds == 0.0

		fold_count = folds.floor
		folds_doubled = fold_count * 2

		remainder = folds % 1.0
		angle_for_remainder = remainder * (1.0 / (fold_count + 1)) 
		angle_per_step = ((1.0 - angle_for_remainder) / folds_doubled)

		# Rotate left half of one slice
		start_radians = RADIANS_UP - (((RADIANS_PER_CIRCLE - (RADIANS_PER_CIRCLE * angle_for_remainder)) / folds_doubled) / 2.0)
		end_radians = start_radians + (RADIANS_PER_CIRCLE * angle_per_step)

		child_count = folds_doubled
		child_count += 1 if (remainder > 0.0)

		with_roll(-(angle_for_remainder) - (angle_per_step / 2.0)) {
			for i in (0...folds_doubled)
				# The rotation here affects the clip planes and the actor
				with_roll(-angle_per_step * i + (angle_for_remainder / 2.0)) {
					# Create the two clip planes (a V-shape)
					with_clip_plane([-Math.sin(start_radians), -Math.cos(start_radians), 0.0, 0.0]) {
						with_clip_plane([Math.sin(end_radians), Math.cos(end_radians), 0.0, 0.0]) {
							# Flip every other slice left-right so the edges mesh perfectly
							if i.is_odd?
								with_scale(-1, 1) { yield :child_index => i, :total_children => folds_doubled }
							else
								yield :child_index => i, :total_children => total_children
							end
						}
					}
				}
			end
		}
	end
end
