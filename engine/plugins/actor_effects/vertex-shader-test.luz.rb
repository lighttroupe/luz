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

class ActorEffectVertexShaderText < ActorEffect
	title				"Vertex Shader Test"
	description ""

	categories :transform

	setting 'amount', :float, :default => 0.0..1.0, :shader => true

	CODE = "
			vertex.x += (rand(vertex.xy)-0.5) * amount;
			vertex.y += (rand(vertex.yx)-0.5) * amount;
		"

	def render
		return yield if amount == 0.0

		with_vertex_shader_snippet(CODE, self) {
			yield
		}
	end
end
