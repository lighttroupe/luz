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

class ActorEffectSpotlight < ActorEffect
	title				'Spotlight'
	description 'A spotlight is a combination of the brightening draw mode, alpha control, a stack, and scaling.'

	setting 'number', :integer, :range => 1..1000, :default => 1..2
	setting 'roll', :float, :range => -1000.0..1000.0, :default => 0.0..1.0
	setting 'smallest', :float, :range => 0.0..1000.0, :default => 1.0..1.0
	setting 'height', :float, :range => 0.0..1000.0, :default => 0.5..1.0
	setting 'alpha', :float, :range => 0.0..1.0, :default => 0.5..1.0

	def render
		with_multiplied_alpha(alpha) {
			with_pixel_combine_function(:brighten) {
				for i in 0...number
					i.distributed_among(number, 1.0..smallest) { |scale_amount|
						with_scale(scale_amount) {
							i.distributed_among(number, 1.0..roll) { |roll_amount|
								with_roll(roll_amount) {
									with_translation(0,0,(i.to_f/number) * height) {
										yield :child_index => i, :total_children => number
									}
								}
							}
						}
					}
				end
			}
		}
	end
end
