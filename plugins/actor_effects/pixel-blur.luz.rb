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

class ActorEffectPixelBlur < ActorEffect
	title				"Pixel Blur"
	description "Averages several nearby pixels."

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'samples', :integer, :range => 1..8, :default => 1..4, :shader => true
	setting 'sample_distance', :float, :range => 0.0..1.0, :default => 0.004..1.0, :shader => true

	CODE = "
		vec4 accumulator = vec4(0.0,0.0,0.0,0.0);

		output_rgba *= texture2D(texture0, texture_st);

		for(int i=-samples ; i<=samples ; i++) {
			if(i != 0) {
				accumulator += texture2D(texture0, texture_st + vec2(float(i) * (sample_distance / 100.0), 0));
			}
		}

		for(int i=-samples ; i<=samples ; i++) {
			if(i != 0) {
				accumulator += texture2D(texture0, texture_st + vec2(0, float(i) * (sample_distance / 100.0)));
			}
		}

		accumulator /= float(samples * 4);

		output_rgba = mix(output_rgba, accumulator, amount);
	"

	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
