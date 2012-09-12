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
	HIT_TEST_INCREMENT = 1		# always 1, except for testing visually

	# Enable and initialize hit-testing mode, which 
	def with_hit_testing
		$engine.with_env(:hit_test, true) {
			$hit_test_id = 0
			$hit_test_options = {}
			yield
		}
	end

	def next_hit_test_id
		$hit_test_id += HIT_TEST_INCREMENT
		return $hit_test_id
	end

	def with_unique_hit_test_color_for_object(object, user_data_integer=0)
		hit_test_id = next_hit_test_id
		$hit_test_options[[hit_test_id, user_data_integer]] = object
		saved = GL.GetColorArray
		GL.Color4ub(hit_test_id, user_data_integer, 0, 255)
		yield
		GL.Color(*saved)
	end

#	def with_hit_test_id(hit_test_id, user_data, object)
#		$hit_test_options[[hit_test_id, user_data]] = object
#		GL.Color4ub(hit_test_id, user_data, 0, 255)
#		yield
#	end

	# returns [hit_test_id, handle_id] or [0, nil]
	def hit_test_object_at_luz_coordinates(x, y)		# coordinates with 0-centered unit square
		pixel_x, pixel_y = (x + 0.5) * $application.width, ((y + 0.5)) * $application.height
		hit_test_object_at(pixel_x, pixel_y)
	end

	def hit_test_object_at(x, y)		# pixel coordinates
		color = glReadPixels(x, y, 1, 1, GL_RGB, GL_UNSIGNED_BYTE).unpack("CCC")
		object = $hit_test_options[[color[0], color[1]]]
		return [object, color[1]]
	end
end
