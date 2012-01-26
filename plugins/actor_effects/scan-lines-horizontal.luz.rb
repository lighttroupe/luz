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

class ActorEffectScanLinesHorizontal < ActorEffect
	title				"Scan Lines Horizontal"
	description "Creates horizontal scanlines in images, with optional fading and horizontal translation."

	setting 'size', :float, :range => 0.0..1.0, :default => 0.05..1.0, :shader => true
	setting 'fade_one', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'offset_one', :float, :range => -1.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'fade_two', :float, :range => 0.0..1.0, :default => 0.5..1.0, :shader => true
	setting 'offset_two', :float, :range => -1.0..1.0, :default => 0.0..1.0, :shader => true

	CODE = "
		if (mod(pixel_xyzw.y, size) >= (size / 2.0)) {
			texture_st.s -= (offset_one);
			output_rgba.a *= (1.0-fade_one);
		} else {
			texture_st.s -= (offset_two);
			output_rgba.a *= (1.0-fade_two);
		}
	"

	def render
		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
