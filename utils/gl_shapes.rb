#
# Shapes holds methods for generating 2D tessellatable shapes.
#
require 'path'

module Shapes
	def self.Circle(radius, points)
		radians_step = ((Math::PI * 2.0) / points)		# Total radians / total points
		radians = first_radian = Math::PI / 2		# Start at the 'top'

		# Add center to make a nice TRIANGLE_FAN (see OpenGL docs)
		vertices = []

		for point in 0..(points-1)
			# Add point
			vertices << (radius * Math.cos(radians))
			vertices << (radius * Math.sin(radians))
			radians += radians_step
		end

		# Add first/final point to close the shape
		vertices << (radius * Math.cos(first_radian))
		vertices << (radius * Math.sin(first_radian))
		vertices
	end

	def self.Ring(radius, points)
		radians_step = ((Math::PI * 2.0) / points)		# Total radians / total points
		radians = first_radian = Math::PI / 2		# Start at the 'top'

		vertices = Array.new
		for point in 0..(points-1)
			# Add point
			vertices << (radius * Math.cos(radians))
			vertices << (radius * Math.sin(radians))
			radians += radians_step
		end
		vertices << vertices[0]
		vertices << vertices[1]
		vertices
	end

	def self.VariableCircle(arms, points_per_arm, &radius_proc)
		# Basically we are plotting a circle, but we vary the radius with each point.
		# To produce a nice curve, we use the output of cos() to determine the radius.
		radians_step = ((Math::PI * 2.0) / (arms * points_per_arm))		# Total radians / total points
		radians = first_radian = Math::PI / 2		# Start at the 'top'

		# Add center of flower to make a nice TRIANGLE_FAN (see OpenGL docs)
		vertices = []

		for arm in 0..(arms-1)
			for point in 0..(points_per_arm-1)
				radius = radius_proc.call(point.to_f / points_per_arm.to_f)
				first_radius ||= radius

				# Add point
				vertices << (radius * Math.cos(radians))
				vertices << (radius * Math.sin(radians))

				# Using modulus here lets us start at any radians value we like
				radians = (radians + radians_step) % (Math::PI * 2)
			end
		end

		# Add first/final point to close the shape
		vertices << (first_radius * Math.cos(first_radian))
		vertices << (first_radius * Math.sin(first_radian))

		vertices
	end

	def self.RoundedRectangle(radius_x, radius_y, knob_x, knob_y, detail)
		knob_x_inv = 1.0 - knob_x
		knob_y_inv = 1.0 - knob_y

		path = Path.new
		path.start_at(-radius_x * knob_x_inv, radius_y)		# top left
		path.line_to(radius_x * knob_x_inv, radius_y)			# top right
		path.arc_to(radius_x - (knob_x / 2), radius_y - (knob_y / 2), radius_x * knob_x, radius_y * knob_y, Math::PI / 2, 0, detail)
		path.line_to(radius_x, -radius_y * knob_y_inv)		# right bottom
		path.arc_to(radius_x - (knob_x / 2), -radius_y + (knob_y / 2), radius_x * knob_x, radius_y * knob_y, Math::PI * 2, (Math::PI / 2) * 3, detail)
		path.line_to(-radius_x * knob_x_inv, -radius_y)		# bottom left
		path.arc_to(-radius_x + (knob_x / 2), -radius_y + (knob_y / 2), radius_x * knob_x, radius_y * knob_y, (Math::PI / 2) * 3, Math::PI, detail)
		path.line_to(-radius_x, radius_y * knob_y_inv)		# left bottom
		path.arc_to(-radius_x + (knob_x / 2), radius_y - (knob_y / 2), radius_x * knob_x, radius_y * knob_y, (Math::PI), Math::PI / 2, detail)
		path
	end
end
