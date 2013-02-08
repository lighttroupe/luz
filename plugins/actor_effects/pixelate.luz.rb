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

class ActorEffectPixelate < ActorEffect
	title				"Pixelate"
	description "Draws image at a lower resolution."

	categories :color

	setting 'segments_x', :integer, :range => 1..1000, :default => 100..1000, :shader => true
	setting 'segments_y', :integer, :range => 1..1000, :default => 100..1000, :shader => true

	def render
		code = "
			float x = floor(texture_st.s * float(segments_x));
			float y = floor(texture_st.t * float(segments_y));

			texture_st.s = (x * (1.0 / float(segments_x)));
			texture_st.t = (y * (1.0 / float(segments_y)));
		"

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
