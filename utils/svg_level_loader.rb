###############################################################################
#  Copyright 2011 Ian McIntosh <ian@openanswers.org>
###############################################################################

#require 'rubygems'		# Just for CP::Vec2 ?
#require 'chipmunk'

require 'rexml/document'
include REXML

require 'matrix'

require 'color'

class SVGLevelLoader
	include REXML
	INFINITY = 1/0.0
	POINTS_PER_BEZIER = 20

	Layer = Struct.new(:index, :name, :options)

	RectObject = Struct.new(:x, :y, :width, :height, :options)
	PathObject = Struct.new(:x, :y, :width, :height, :vertices, :options)
	GroupObject = Struct.new(:objects, :options)

	def load(svg_path, project_path)
		puts "\n#{'=' * 60}\nSVGLevelLoader::load(#{svg_path})..."
		@svg_path, @project_path = svg_path, File.expand_path(project_path)
		@doc = Document.new(File.new(svg_path))
		@width = @doc.root.attribute('width').to_s.to_f
		@height = @doc.root.attribute('height').to_s.to_f
		@filter_to_blend_mode = parse_filters
	end

=begin

<defs id="defs3251">
	<filter inkscape:collect="always" id="filter4339">
		<feBlend inkscape:collect="always" mode="multiply" in2="BackgroundImage" id="feBlend4341" />
	</filter>
</defs>
=end

	def parse_filters
		hash = {}
		@doc.root.each_element('defs') { |defs|
			defs.each_element('filter') { |filter|
				id = filter.attribute('id').to_s
				filter.each_element('feBlend') { |blend|
					hash[id] = blend.attribute('mode').to_s
				}
			}
		}
		return hash
	end

	def each_element(&proc)
		index = 0
		xml_node = @doc.root
		xml_node.each_element('g') { |g|
			parse_layer(g, index, Matrix.identity(3), &proc)
			index += 1
		}
	end

	def each_layer
		index = 0
		@doc.root.each_element('g') { |g|
			name, options = parse_layer_options(g.attribute('inkscape:label').to_s)
			options.merge!(parse_style_attribute(g))
			yield Layer.new(index, name, options)
			index += 1
		}
	end

	def parse_layer_options(text)
		layer_name = ''
		options = {}
		if i=text.index('(')
			layer_name = text[0,i].strip
			text[i+1, text.length-i-2].split(',').each { |option|
				name, value = option.split(':')
				options[name.strip.gsub('-','_').to_sym] = value.strip
			}
		else
			layer_name = text.strip
		end
		[layer_name, options]
	end

private

	def accumulate_transform(matrix, transform)
		# http://www.w3.org/TR/SVG11/coords.html#EstablishingANewUserSpace
		transform.scan(/translate\((.*),(.*)\)/) { |m|
			tx, ty = m[0].to_f, m[1].to_f
			return matrix * Matrix[[1,0,tx],[0,1,ty],[0,0,1]]
		}
		transform.scan(/matrix\((.*),(.*),(.*),(.*),(.*),(.*)\)/) { |m|
			a, b, c, d, e, f =  m[0].to_f, m[1].to_f, m[2].to_f, m[3].to_f, m[4].to_f, m[5].to_f
			return matrix * Matrix[[a,c,e],[b,d,f],[0,0,1]]
		}
		transform.scan(/scale\((.*),(.*)\)/) { |m|
			scale_x, scale_y = m[0].to_f, m[1].to_f
			return matrix * Matrix[[scale_x,0,0],[0,scale_y,0],[0,0,1]]
		}
		matrix
	end

	def transform_point(x, y, transform_matrix)
		# 3x3 matrix * vertical[x, y, 0]
		m = transform_matrix * Matrix.column_vector([x,y,1])
		[m[0,0],m[1,0]]
	end

#	def matrix_2d_translate(matrix)
#		[matrix[0,2], matrix[1,2]]
#	end

	def parse_layer(xml_node, layer_index, transform_matrix, &proc)
		transform_matrix = accumulate_transform(transform_matrix, xml_node.attribute('transform').to_s)

		# Each element in order (bottom to top)
		xml_node.each_element { |e|
			title = nil ; e.each_element('title') { |t| title = t.text }

			# Parse and yield objects
			case e.name
			when 'rect'
				parse_rect(e, transform_matrix) { |rect|
					rect.options[:title] = title
					proc.call(layer_index, rect)
				}

			when 'image'
				parse_image(e, transform_matrix) { |image|
					image.options[:title] = title
					proc.call(layer_index, image)
				}

			when 'path'
				if e.attribute('sodipodi:type').to_s == 'arc'
					parse_path(e, transform_matrix) { |path|
						path.options[:title] = title
						proc.call(layer_index, path)
					}

				else
					#	rect = ...
					# 	rect.options[:shape] = 'circle'
					# end
					parse_path(e, transform_matrix) { |path|
						path.options[:title] = title
						proc.call(layer_index, path)
					}
				end

			when 'g'
				objects = []
				parse_layer(e, layer_index, transform_matrix) { |_li, object|
					objects << object
				}

				id = e.attribute('id').to_s
				options = {:id => id, :title => title}
				e.each_element('desc') { |desc|
					options.merge!(text_to_options_hash(id, desc.text))
				}

				proc.call(layer_index, GroupObject.new(objects, options))
			end
		}
	end

	def parse_rect(p, transform_matrix)
		id = p.attribute('id').to_s
		options = {:id => id}
		p.each_element('desc') { |desc|
			options.merge!(text_to_options_hash(id, desc.text))
		}

		# Fill Color / Alpha
		options.merge!(parse_style_attribute(p))

		#
		# X, Y, Width, Height
		#
		x = p.attribute('x').to_s.to_f
		y = p.attribute('y').to_s.to_f
		width = p.attribute('width').to_s.to_f
		height = p.attribute('height').to_s.to_f

		# Move x,y to the center (a better handle)
		x += width/2.0
		y += height/2.0

		transform_matrix = accumulate_transform(transform_matrix, p.attribute('transform').to_s)

		# Apply accumulated transform
		x, y = transform_point(x, y, transform_matrix)		# AFTER applying p's transform

		# Inkscape coordinates to Luz coordinates
		x, y = inkscape_to_luz(x, y)

		width /= @width
		height /= @height

		# Extract angle and sizing info from the current transformation matrix
		a, b, c, d = transform_matrix[0,0], transform_matrix[1,0], transform_matrix[0,1], transform_matrix[1,1]
		angle = -(Math.acos(a) / (2*Math::PI))
		angle = -angle if b > 0		# to Luz rotation angle (otherwise top half and bottom half appear the same)

		hscale = a.to_f / d.to_f	#/d
		vscale = 1.0	#/d
		#puts "#{options[:id]}: x:#{x} y:#{y} d: #{d} a: #{a} hscale: #{hscale} vscale: #{vscale} acos: #{Math.acos(a)} luzangle: #{angle}"

		options[:angle] = angle
		options[:scale_x] = vscale
		options[:scale_y] = hscale.nan? ? -1.0 : hscale		# with matrix rotation, they're equal, when a == -d it seems to be a scale (all horizontal/vertical scaling can be accomplished with scale_y and rotation)

		yield RectObject.new(x, y, width, height, options)
	end

	def inkscape_to_luz(x, y)
		[((x / @width) - 0.5), (0.5 - (y / @height))]
	end

	def parse_image(p, transform_matrix)
		parse_rect(p, transform_matrix) { |rect|
			path = p.attribute('xlink:href').to_s
			path = path.gsub(/file:.*\/(worlds\/.*\....)/, '\1')
			path = path.gsub(/file:.*\/(images\/.*\....)/, '\1')
			path = path.gsub('%20',' ')
			image = $engine.load_images(path)
			rect.options[:image] = image.first if image	# no gif support yet
			yield rect
		}
	end

	def parse_path(p, transform_matrix)
		id = p.attribute('id').to_s
		options = {:id => id}
		p.each_element('desc') { |desc|
			options.merge!(text_to_options_hash(id, desc.text))
		}

		# Fill Color / Alpha
		#options[:fill_color] = parse_style_attribute(p)
		options.merge!(parse_style_attribute(p))

		transform_matrix = accumulate_transform(transform_matrix, p.attribute('transform').to_s)

		path = []
		relative = false

		#
		# Parse the SVG path format, which is a form of run-length encoding
		#
		list = p.attribute('d').to_s.split

		while not list.empty?
			command = list.shift

			case command
			when 'm'		# moveto relative
				mode = :moveto
				relative = true
				throw 'unhandled' unless path.empty?
				#yield PathObject.new(path, options) unless path.empty?
				path = []

			when 'M'		# moveto absolute
				mode = :moveto
				relative = false
				throw 'unhandled' unless path.empty?
				#yield PathObject.new(path, options) unless path.empty?
				path = []

			when 'L'		# lineto absolute
				mode = :lineto
				relative = false

			when 'l'		# lineto relative
				mode = :lineto
				relative = true

			when 'a'		# Relative elliptical arc
				while list.first =~ /-?\d,-?\d/
					p0 = path.last
					rxry = coordinate_text_to_vec2(list.shift)
					_unused_x_rotation = list.shift.to_i
					_unused_large_arc_flag = list.shift.to_i
					_unused_sweep_flag = list.shift.to_i
					p1 = coordinate_text_to_vec2(list.shift) + p0

					center_point = (p0 + p1) / 2
					delta_x = (p0.x - p1.x)
					(0.0..1.0).step(1.0/POINTS_PER_BEZIER) { |t|
						# HACK: use delta_x to determine which way to 'wind', as opposed to going "left"
						if delta_x > 0
							new_point = center_point + CP::Vec2.new(rxry.x * Math.cos(t*Math::PI), rxry.y*Math.sin(t*Math::PI))
						elsif delta_x < 0
							new_point = center_point - CP::Vec2.new(rxry.x * Math.cos(t*Math::PI), rxry.y*Math.sin(t*Math::PI))
						else
							raise "We're using delta_x of p0 and p1 to determine which way to wind the arc, but Inkscape gave us a vertical line segment."
						end
						path << new_point unless (!path.empty? and path.last == new_point)
					}
				end

			when 'c'		# relative bezier curve
				# each group of 3 x,y pairs is one bezier curve
				while list.first =~ /-?\d,-?\d/
					p0 = path.last
					p1 = coordinate_text_to_vec2(list.shift) + p0
					p2 = coordinate_text_to_vec2(list.shift) + p0
					p3 = coordinate_text_to_vec2(list.shift) + p0

					# Bezier curve interpretation. The 0.05 is arbitrary.
					(0.0..1.0).step(1.0/POINTS_PER_BEZIER) { |t|
						new_point = (p0 * ((1.0-t)**3)) + p1*t*3.0*((1.0-t)**2) + p2 * (t**2)*3*(1.0-t) + p3*(t**3)
						path << new_point unless (!path.empty? and path.last == new_point)
					}
				end

			when 'C'		# absolute bezier curve
				# each group of 3 x,y pairs is one bezier curve
				while list.first =~ /-?\d,-?\d/
					p0 = path.last
					p1 = coordinate_text_to_vec2(list.shift)
					p2 = coordinate_text_to_vec2(list.shift)
					p3 = coordinate_text_to_vec2(list.shift)

					(0.0..1.0).step(1.0/POINTS_PER_BEZIER) { |t|
						new_point = (p0 * ((1.0-t)**3)) + p1*t*3.0*((1.0-t)**2) + p2 * (t**2)*3*(1.0-t) + p3*(t**3)
						path << new_point unless (!path.empty? and path.last == new_point)
					}
				end

			when 'z','Z'		# end path
				path << CP::Vec2.new(path.first.x, path.first.y) if path.first

			when /-?\d,-?\d/
				vertex = CP::Vec2.new(*(command.split(',').map { |s| s.to_f }))

				if relative
					if path.empty?
						#puts "starting relative #{vertex}"
						path << (vertex)
					else
						#puts "continuing relative #{vertex}"
						path << (path.last + vertex)
					end
				else
					#puts "absolute point #{vertex}"
					path << (vertex)
				end

			else
				puts '===================='
				puts "warning: use of unsupported feature (#{command}) in path Id #{id}"
				puts '===================='
			end
		end

		# apply global transformation
		path.each { |vertex|
			vertex.x, vertex.y = transform_point(vertex.x, vertex.y, transform_matrix)
			vertex.x, vertex.y = inkscape_to_luz(vertex.x, vertex.y)
		}

		unless path.empty?
			x, y, width, height = path_x_y_width_height(path)
			yield PathObject.new(x, y, width, height, path, options)
		end
	end

	def path_x_y_width_height(vertices)
		min_x, max_x, min_y, max_y = INFINITY, -INFINITY, INFINITY, -INFINITY

		vertices.each { |v|
			min_x = v.x if v.x < min_x
			min_y = v.y if v.y < min_y
			max_x = v.x if v.x > max_x
			max_y = v.y if v.y > max_y
		}

		width, height = (max_x - min_x), (max_y - min_y)
		return min_x + width/2, min_y + height/2, width, height
	end

	#
	# Utilities
	#
	def text_to_options_hash(id, text)
		hash = {}
		text.split("\n").each { |line|
			name, value = line.split(':', limit=2).map { |s| s.strip }
			next unless name
			key = name.gsub('-', '_').to_sym
			puts "warning: duplicate key #{key} for id #{id}" if hash[key]
			hash[key] = value
		}
		hash
	end

	def coordinate_text_to_vec2(text)
		CP::Vec2.new(*text.split(',').map { |s| s.to_f })
	end

	def parse_hex_color(text)
		return nil if text.nil? or text == 'none' 
		Color.new(text.sub('#','').scan(/(..)/).map { |hex| hex.first.to_i(16).to_f / 255 } )
	end

	def parse_style_attribute(node)
		hash = {:fill_color => Color.new([1,1,1,1]), :stroke_color => nil, :stroke_width => 1.0}

		if (styles=node.attribute('style'))
			styles.to_s.split(';').each { |style|
				name, value = *(style.split(':'))
				case name
				when 'fill'
					hash[:fill_color] = parse_hex_color(value)
				when 'opacity', 'fill-opacity'
					hash[:fill_color].alpha *= value.to_f
				when 'stroke'
					hash[:stroke_color] = parse_hex_color(value)
				when 'stroke-width'
					hash[:stroke_width] = value.to_i		# "1px" to 1
				when 'filter'
					if value =~ /url\(\#(.*)\)/
						hash[:draw_method] = @filter_to_blend_mode[$1]
					else
						puts "warning: don't know what to do with filter #{value} in parse_style_attribute"
					end
				end
			}
		end

		return hash
	end
end
