class ChipmunkTessellator
	def initialize
		@tessellator = GLU.NewTess

		# Add callbacks.  All do pretty much the minimum.
		GLU.TessCallback(@tessellator, GLU::TESS_BEGIN, proc { |shape_type| @shape_type = shape_type }) # add GL.Color(rand,rand,rand) before Begin to see shapes
		GLU.TessCallback(@tessellator, GLU::TESS_EDGE_FLAG, proc { |e| })
		GLU.TessCallback(@tessellator, GLU::TESS_VERTEX, proc { |v| @vertex_list << CP::Vec2.new(v[0], v[1]) })
		GLU.TessCallback(@tessellator, GLU::TESS_COMBINE, proc { |coords, vertex_data, weight| coords[0,2] })
		GLU.TessCallback(@tessellator, GLU::TESS_END, proc { end_shape })		# Send shape to chipmunk
		GLU.TessCallback(@tessellator, GLU::TESS_ERROR, proc { |error_code| puts "Tessellation Error: #{GLU.ErrorString(error_code)}" })
	end

	def convex_shape_plus_triangle(convex, triangle)
		non_overlapping = triangle.dup.delete_if { |v| convex.index(v) }

		# A triangle must match two vertices, otherwise we can't weld it on
		return nil unless non_overlapping.size == 1

		# On which indices of 'convex' does the triangle touch?
		overlap_indices = [convex.index(triangle[0]), convex.index(triangle[1]), convex.index(triangle[2])]
		overlap_indices.delete(nil)

		# special case
		if ((overlap_indices.first == 0) and (overlap_indices.last == (convex.size-1))) or ((overlap_indices.first == (convex.size-1)) and (overlap_indices.last == 0))
			proposed_convex = convex.dup << non_overlapping.first
			if CP::Shape::Poly.valid?(proposed_convex) or CP::Shape::Poly.valid?(proposed_convex.reverse)
				#puts "inserted point at end of convex list"
				return proposed_convex
			end
		else
			proposed_convex = convex.dup.insert(overlap_indices.max, non_overlapping.first)
			if CP::Shape::Poly.valid?(proposed_convex) or CP::Shape::Poly.valid?(proposed_convex.reverse)
				#puts "inserted point into convex shape at index #{overlap_indices.max}"
				return proposed_convex
			end
		end
		return nil
	end

	def end_shape
		# one of: GL_TRIANGLE_FAN, GL_TRIANGLE_STRIP, GL_TRIANGLES
		convex_shape = []
		yield_triangles { |triangle|
			if convex_shape.empty?
				# Start convex shape off as the triangle
				convex_shape = triangle.dup
			else
				# Attempt to merge the triangle onto the existing convex shape
				proposed_convex_shape = convex_shape_plus_triangle(convex_shape, triangle)
				if proposed_convex_shape
					# Save and continue building...
					convex_shape = proposed_convex_shape
				else
					# Couldn't add it on, so consider this convex shape done
					@proc.call(convex_shape)
					convex_shape = triangle.dup		# Continue with triangle
				end
			end
		}
		@proc.call(convex_shape) unless convex_shape.empty?
		@vertex_list.clear
	end

	def yield_triangles
		case @shape_type
		when GL::TRIANGLES
			0.upto((@vertex_list.size / 3)-1) { |i|
				yield @vertex_list[i*3, 3]
			}
		when GL::TRIANGLE_STRIP
			puts "ChipmunkTessellator: using untested GL::TRIANGLE_STRIP"
			# yield 0,1,2 1,2,3 2,3,4
			@vertex_list.each_cons(3) { |triangle|
				yield triangle
			}

		when GL::TRIANGLE_FAN
			puts "ChipmunkTessellator: using untested GL::TRIANGLE_FAN"
			# yield 0,1,2 0,2,3 0,3,4 -- each_cons(3) replacing first element
			center_point = @vertex_list.first
			@vertex_list.each_cons(3) { |triangle|
				yield [center_point.dup, triangle[1], triangle[2]]
			}
		end
	end

	def tessellate!(vertices, &proc)
		@shape_type = nil
		@vertex_list = []
		@proc = proc

		GLU.TessBeginPolygon(@tessellator, nil)
			GLU.TessBeginContour(@tessellator)
				vertices.each { |vertex|
					GLU.TessVertex(@tessellator, [vertex.x, vertex.y], [vertex.x, vertex.y])
				}
			GLU.TessEndContour(@tessellator)
		GLU.TessEndPolygon(@tessellator)
	end
end
