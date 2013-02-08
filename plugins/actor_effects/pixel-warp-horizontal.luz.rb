 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
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

class ActorEffectPixelWarpHorizontal < ActorEffect
	title				"Pixel Warp Horizontal"
	description "Offsets pixels in a wavy way."

	categories :color

	setting 'amount', :float, :default => 0.0..1.0, :shader => true
	setting 'frequency', :float, :default => 0.1..1.0, :shader => true

	CODE = "
		texture_st.s += amount * 0.2 * (cos(texture_st.t * mix(1, 500, frequency)));
		texture_st.t += amount * 0.2 * (cos(texture_st.s * mix(1, 500, frequency)));
	"

	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
