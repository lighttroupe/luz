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

class ActorEffectPixelColorReduce < ActorEffect
	title				"Pixel Color Reduce"
	description ""

	setting 'segments', :integer, :range => 1..1000, :default => 100..1000, :shader => true

	def render
		code = "
			output_rgba *= texture2D(texture0, texture_st);

			output_rgba.r = floor(output_rgba.r * float(segments)); // / segments; 
			output_rgba.g = floor(output_rgba.g * float(segments)); // / segments; 
			output_rgba.b = floor(output_rgba.b * float(segments)); // / segments;
			
			output_rgba.rgb /= float(segments); 
		"

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
