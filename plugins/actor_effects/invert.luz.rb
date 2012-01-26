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

class ActorEffectInvert < ActorEffect
	title				"Invert"
	description "Inverts pixel color components."

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true

	def render
		return yield if amount == 0.0

		code = "
			output_rgba *= texture2D(texture0, texture_st);
			output_rgba.r = mix(output_rgba.r, 1.0 - output_rgba.r, amount);
			output_rgba.g = mix(output_rgba.g, 1.0 - output_rgba.g, amount);
			output_rgba.b = mix(output_rgba.b, 1.0 - output_rgba.b, amount);
		"

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
