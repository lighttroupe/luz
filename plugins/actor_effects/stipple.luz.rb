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

class ActorEffectStipple < ActorEffect
	title				"Stipple"
	description "Represent image using a grid of dots."

	setting 'segments', :integer, :range => 1..1000, :default => 100..10000, :shader => true
	setting 'size', :float, :range => 0.0..1.0, :default => 1.0..1.0, :shader => true

	def render
		code = "
			float floor_x = floor(texture_st.x * float(segments));
			float floor_y = floor(texture_st.y * float(segments));

			float square_side_length = (1.0 / float(segments));
			float center_x = (floor_x * square_side_length) + (square_side_length * 0.5);
			float center_y = (floor_y * square_side_length) + (square_side_length * 0.5);

			// from center
			float delta_x = (texture_st.x - center_x);
			float delta_y = (texture_st.y - center_y);

			float radius_squared = (square_side_length * 0.707 * size);		// sqrt(0.5^2 + 0.5^2) = 0.707 (stipple circles touches square corner at size == 1.0)
			radius_squared = radius_squared * radius_squared;

			if(((delta_x*delta_x) + (delta_y*delta_y)) < radius_squared) {
				texture_st.x = center_x;
				texture_st.y = center_y;
			} else {
				return;
			}
		"

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
