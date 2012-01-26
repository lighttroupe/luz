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

class ActorEffectPixelDisplacementMap < ActorEffect
	title				"Pixel Displacement Map"
	description "Uses chosen image to offset actor's pixels."

	setting 'displacement_map', :image, :shader => true
	setting 'amount', :float, :range => -10.0..10.0, :default => 0.0..2.0, :shader => true

	CODE = "
		vec4 displacement_rgba = texture2D(displacement_map, texture_st);

		texture_st.s += (displacement_rgba.r + displacement_rgba.g - 1.0) * amount;
		texture_st.t += (displacement_rgba.b + displacement_rgba.a - 1.0) * amount;
	"

	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
