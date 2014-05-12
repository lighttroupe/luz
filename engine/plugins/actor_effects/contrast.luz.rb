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

class ActorEffectContrast < ActorEffect
	title				"Contrast"
	description "Increase or decrease the contrast of the image. Amounts over 1.0 make colors more extreme, while amounts under 1.0 move colors towards gray."

	categories :color

	setting 'amount', :float, :range => 0.0..2.0, :default => 1.0..2.0, :shader => true

	def render
		return yield if amount == 1.0

		if amount < 1.0
			code = "
				output_rgba *= texture2D(texture0, texture_st);

				float decontrast = (1.0 - amount);

				// move each color channel towards a pure gray
				output_rgba.r = mix(output_rgba.r, 0.5, decontrast);
				output_rgba.g = mix(output_rgba.g, 0.5, decontrast);
				output_rgba.b = mix(output_rgba.b, 0.5, decontrast);
			"
		elsif amount > 1.0
			code = "
				output_rgba *= texture2D(texture0, texture_st);

				// move each color channel towards average color
				if(output_rgba.r < 0.5) {
					output_rgba.r *= mix(output_rgba.r, 0.0, amount-1.0);
				} else {
					output_rgba.r = mix(output_rgba.r, 1.0, amount-1.0);
				}
				if(output_rgba.g < 0.5) {
					output_rgba.g = mix(output_rgba.g, 0.0, amount-1.0);
				} else {
					output_rgba.g = mix(output_rgba.g, 1.0, amount-1.0);
				}
				if(output_rgba.b < 0.5) {
					output_rgba.b = mix(output_rgba.b, 0.0, amount-1.0);
				} else {
					output_rgba.b = mix(output_rgba.b, 1.0, amount-1.0);
				}
			"
		end

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
