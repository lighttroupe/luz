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

module DrawingHitTesting
	def with_hit_test
		$engine.with_env(:hit_test, true) {
			$hit_test_id = 0
			$hit_test_options = {}
			yield
		}
	end

	def next_hit_test_id
		$hit_test_id += 1
		return $hit_test_id
	end

	HANDLE_POSITION = 1
	def add_hit_test_option(hit_test_id, handle_id, object, x, y, z)
		$hit_test_options[[hit_test_id, handle_id]] = object
		GL.Color4ub(hit_test_id, HANDLE_POSITION, 0, 255)
		GL.Begin(GL::POINTS) ; GL.Vertex(x, y, z) ; GL.End
	end

	# returns [hit_test_id, handle_id] or [0, nil]
	def hit_test_object_handles(x, y)
		color = glReadPixels(x, y, 1, 1, GL_RGB, GL_UNSIGNED_BYTE).unpack("CCC")
		object = $hit_test_options[[color[0], color[1]]]
		return [object, color[1]]
	end
end
