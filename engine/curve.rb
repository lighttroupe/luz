 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
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

require 'parent_user_object'

class Curve < ParentUserObject
	title 'Curve'

	attr_reader :vector, :approximation

	def to_yaml_properties
		['@vector', '@approximation'] + super
	end

	def effects
		[]
	end

	def after_load
		set_default_instance_variables(:title => 'New Curve', :vector => (0...9).to_a.collect {|x| x / 8.0 }, :approximation => [0.0, 1.0])
		super
	end

	def vector=(rhs)
		@vector, @last_x_unclamped = rhs, nil		# NOTE: Clears cached value
	end

	def approximation=(rhs)
		@approximation, @last_x_unclamped = rhs, nil		# NOTE: Clears cached value
	end

	def value(x_unclamped)
		return @last_value if x_unclamped == @last_x_unclamped		# Simple cache

		x = x_unclamped.clamp(0.0, 1.0)

		step_size = (1.0 / (@approximation.size - 1))

		ia = (x * (@approximation.size - 1)).floor.to_i
		ib = (ia + 1) % (@approximation.size)

		percent_between = (x - (ia * step_size)) / step_size

		@last_x_unclamped, @last_value = x_unclamped, percent_between.scale(@approximation[ia], @approximation[ib])
		return @last_value
	end

	def up?
		@vector.first == 0.0 and @vector.last == 1.0
	end

	def down?
		@vector.first == 1.0 and @vector.last == 0.0
	end

	def middle?
		@vector.first == 0.5 and @vector.last == 0.5
	end

	def looping?
		@vector.first == @vector.last
	end

	def linear?
		(@approximation.size == 2) and up?
	end
end
