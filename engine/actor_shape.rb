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

class ActorShape < Actor
	description 'Base class for shapes'
	virtual

	ORIGIN = [0.0, 0.0]

	# TODO: of course this will come from the 'style' setting
	#setting 'texture_method', :integer, :range => 1..2, :default => 1..2, :breaks_cache => true

	attr_reader :shape

	def texture_coord(v)
		v
	end

	def vertex(v)
		v
	end

	def combine(coords, vertex_data, weight)
		coords[0,2]
	end

	POINTS_PER_VERTEX = 2

	def render
		# Call shape method of child class.  Returns array of x,y pairs, or array of arrays: [x1,y1,x2,y2, ... ,xn,yn]
		self.shape { |options| render_with_options(options) }
	end

	def render_with_options(options)
		options = {:type => :polygon, :shape => []}.merge(options)

		# If there's only one array of floats, change it to an array with an array of floats
		options[:shape] = [options[:shape]] unless options[:shape][0].is_a? Array

		#z_width = 0.025

		case options[:type]
		when :triangle_strip
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

		when :polygon
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

			#options[:shape].each_with_index { |shape, index|
				#next if shape.size < 3

				#GL.FrontFace(index.is_odd? ? GL::CCW : GL::CW)
				#GL.Begin(GL::TRIANGLE_STRIP)
					## step to every other index (0,2,4,etc.)
					#0.step(shape.size-1, POINTS_PER_VERTEX) { |points_index|
						#v = shape[points_index, POINTS_PER_VERTEX]		# gets [x,y]
						#tc = texture_coord(v).dup
						#tc[0] = tc[0]	+ RADIUS
						#tc[1] = -(tc[1] - RADIUS)

						#v3d = v + [-z_width]
						#GL.TexCoord(tc) ; GL.Vertex(v3d)

						#v3d = v + [z_width]
						#GL.TexCoord(tc) ; GL.Vertex(v3d)
					#}
				#GL.End
			#}

			#GL.FrontFace(GL::CW)
			#GLU.TessBeginPolygon($tessalator, nil)
			#options[:shape].each { |shape|
				#next if shape.size < 3
				#GLU.TessBeginContour($tessalator)
					## step to every other index (0,2,4,etc.)
					#0.step(shape.size-1, POINTS_PER_VERTEX) { |points_index|
						#v = shape[points_index, POINTS_PER_VERTEX]		# gets [x,y]
						#v3d = v + [-z_width]
						#GLU.TessVertex($tessalator, v3d, v3d)
					#}
				#GLU.TessEndContour($tessalator)
			#}
			#GLU.TessEndPolygon($tessalator)
		else
			throw "unhandled shape type '#{options[:type]}'"
		end
	end
end
