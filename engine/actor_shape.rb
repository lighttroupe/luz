class ActorShape < Actor
	virtual

	description 'Base class for shapes'

	attr_reader :shape

	def render
		shape { |options| render_with_options(options) }		# shape expected to yield array of x,y pairs, or array of arrays: [x1,y1,x2,y2,...]
	end

	def render_with_options(options)
		options = {:type => :polygon, :shape => []}.merge(options)
		options[:shape] = [options[:shape]] unless options[:shape][0].is_a?(Array)

		case options[:type]
		when :triangle_strip
			render_triangle_strip(options)
		when :polygon
			tesselate_polygon(options)
		else
			raise "unhandled shape type '#{options[:type]}'"
		end
	end

private

	POINTS_PER_VERTEX = 2

	def render_triangle_strip(options)
		options[:shape].each { |shape|
			GL.Begin(GL::TRIANGLE_STRIP) # GL::LINE_LOOP
				0.step(shape.size-1, POINTS_PER_VERTEX) { |points_index|
					v = shape[points_index, POINTS_PER_VERTEX]
					tc = texture_coord(v)
					GL.TexCoord(tc[0] + RADIUS, -(tc[1] - RADIUS))
					GL.Vertex(*v)
				}
			GL.End
		}
	end

	def tesselate_polygon(options)
		# Use a (cached) tessalator to generate (OpenGL-compatible) *convex* polygons
		# from our possibly (non-OpenGL-compatible) concave shape.
		unless $tessalator
			$tessalator = GLU.NewTess

			#puts "#{v.collect { |f| sprintf('%4.2f', f)}.join(',')} => #{tc.collect { |f| sprintf('%4.2f', f)}.join(',')}" ;
			# Add callbacks.  All do pretty much the minimum.
			GLU.TessCallback($tessalator, GLU::TESS_BEGIN, proc { |shape_type| GL.Begin(shape_type) }) # add GL.Color(rand,rand,rand) before Begin to see shapes
			GLU.TessCallback($tessalator, GLU::TESS_EDGE_FLAG, proc { |e| GL.EdgeFlag(e) })		# 			[(v[0] + RADIUS), -(v[1] - RADIUS)]
			GLU.TessCallback($tessalator, GLU::TESS_VERTEX, proc { |v| v = vertex(v) ; tc = texture_coord(v) ; GL.TexCoord(tc[0] + RADIUS, -(tc[1] - RADIUS)) ; GL.Vertex(v) })
			GLU.TessCallback($tessalator, GLU::TESS_COMBINE, proc { |coords, vertex_data, weight| combine(coords, vertex_data, weight) })
			GLU.TessCallback($tessalator, GLU::TESS_END, proc { GL.End })
			GLU.TessCallback($tessalator, GLU::TESS_ERROR, proc { |error_code| puts "Tessellation Error: #{GLU.ErrorString(error_code)}" })
		end

		#GL.FrontFace(GL::CCW)
		GLU.TessBeginPolygon($tessalator, nil)
		options[:shape].each { |shape|
			next if shape.size < 3
			GLU.TessBeginContour($tessalator)
				# step to every other index (0,2,4,etc.)
				0.step(shape.size-1, POINTS_PER_VERTEX) { |points_index|
					v = shape[points_index, POINTS_PER_VERTEX]		# gets [x,y]
					GLU.TessVertex($tessalator, v, v)
					#v3d = v + [z_width]
					#GLU.TessVertex($tessalator, v3d, v3d)
				}
			GLU.TessEndContour($tessalator)
		}
		GLU.TessEndPolygon($tessalator)
	end

	def texture_coord(v)
		v
	end

	def vertex(v)
		v
	end

	def combine(coords, vertex_data, weight)
		coords[0,2]
	end
end
