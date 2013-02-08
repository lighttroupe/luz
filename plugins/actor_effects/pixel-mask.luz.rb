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

class ActorEffectPixelMask < ActorEffect
	title				"Pixel Mask"
	description ""

	categories :color

	setting 'red_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'green_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'blue_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'alpha_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true

	CODE = "
		output_rgba *= texture2D(texture0, texture_st);
		if(output_rgba.a < alpha_cutoff || output_rgba.r < red_cutoff || output_rgba.g < green_cutoff || output_rgba.b < blue_cutoff) {
			output_rgba = vec4(0,0,0,0);
		}
	"

	def render
		return yield if (red_cutoff == 0.0 and green_cutoff == 0.0 and blue_cutoff == 0.0 and alpha_cutoff == 0.0)

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
