#
# GLTessellator takes arbitrary shapes (x,y pairs) and turns them into lists of OpenGL-renderable triangles.
#
#  GLTessellator.new.render_filled_path(vertices, :height => 0.1)		# height draws an extruded 3D shape from our 2D vertices
#
class GLTessellator
	def initialize
		@tessellator = GLU.NewTess
		@tessellator_height = 0.0

		# Add callbacks.  All do pretty much the minimum.
		GLU.TessCallback(@tessellator, GLU::TESS_BEGIN, proc { |shape_type| GL.Begin(shape_type) }) # add GL.Color(rand,rand,rand) before Begin to see shapes
		GLU.TessCallback(@tessellator, GLU::TESS_EDGE_FLAG, proc { |e| GL.EdgeFlag(e) })
		GLU.TessCallback(@tessellator, GLU::TESS_VERTEX, proc { |v| GL.TexCoord(v[0] + RADIUS, -(v[1] - RADIUS)) ; GL.Vertex(v[0], v[1], @tessellator_height) })
		GLU.TessCallback(@tessellator, GLU::TESS_COMBINE, proc { |coords, vertex_data, weight| coords[0,2] })
		GLU.TessCallback(@tessellator, GLU::TESS_END, proc { GL.End })
		GLU.TessCallback(@tessellator, GLU::TESS_ERROR, proc { |error_code| puts "Tessellation Error: #{GLU.ErrorString(error_code)}" })
	end

	def render_filled_path(vertices, options={})
		#
		# Optionally turn a 2D shape into 3D
		#
		height = options[:height].to_f
		depth = options[:depth].to_f
		unless height == 0.0 and depth == 0.0
			GL.Begin(GL::TRIANGLE_STRIP)
				vertices.each { |vertex|
					GL.Vertex(vertex.x, vertex.y, height)
					GL.Vertex(vertex.x, vertex.y, -depth)
				}
				GL.Vertex(vertices.first.x, vertices.first.y, height)
				GL.Vertex(vertices.first.x, vertices.first.y, -depth)
			GL.End
		end

		@tessellator_height = height
		GLU.TessBeginPolygon(@tessellator, nil)
			GLU.TessBeginContour(@tessellator)
				vertices.each { |vertex|
					GLU.TessVertex(@tessellator, [vertex.x, vertex.y], [vertex.x, vertex.y])
				}
			GLU.TessEndContour(@tessellator)
		GLU.TessEndPolygon(@tessellator)
	end
end
