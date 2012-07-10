require 'chipmunk_tessellator'
$chipmunk_tessellator ||= ChipmunkTessellator.new

module ChipmunkCreateHelpers
	def create_space
		space = CP::Space.new

		# Allow body sleeping (reduces Chipmunk CPU time and more importantly: cuts down on slow Ruby callbacks)
		space.sleep_time = 0.1
		space.sleep_time_threshold = 1

		# "Setting dim to the average collision shape size is likely to give the best performance." -docs
		# "Setting count to ~10x the number of objects in the space is probably a good starting point." -docs
		dim, count = 0.1, 1000
		space.resize_static_hash(dim, count)
		space.resize_active_hash(dim, count)

		space
	end

	#
	# Chipmunk body helpers		http://beoran.github.com/chipmunk/#Body
	#
	def create_infinite_mass_body_at(point)
		body = CP::Body.new(CP::INFINITY, CP::INFINITY)		# mass, moment_of_inertia
		body.p = point
		return body
	end

	#
	# Chipmunk shape helpers		http://beoran.github.com/chipmunk/#Shape
	#
	def create_shapes_for_object(body, object, offset=CP::ZERO_VEC_2)
		shapes = []

		if object.options[:shape] == 'circle'
			radius = (object.width + object.height)/4
			radius *= as_float(object.options[:radius], 1.0)
			shapes << CP::Shape::Circle.new(body, radius, offset)

		elsif object.options[:shape] == 'polygon'
			# NOTE: removing last vertex solves a bug seen on some Luz+Chipmunk instances (and not others)
			poly = object.options[:shape_vertices]

			begin
				# try to create poly
				shapes << CP::Shape::Poly.new(body, poly, offset)

			rescue ArgumentError
				begin
					# try it wound the other way
					shapes << CP::Shape::Poly.new(body, poly.reverse, offset)

				rescue ArgumentError
					# try it tessellated
					$chipmunk_tessellator.tessellate!(poly) { |convex_poly|
						next if convex_poly.empty?

						begin
							shapes << CP::Shape::Poly.new(body, convex_poly, offset)
						rescue ArgumentError
							begin
								shapes << CP::Shape::Poly.new(body, convex_poly.reverse, offset)
							rescue ArgumentError
								puts "==================================================================="
								puts "error: shape #{object.options[:id]} cannot be tessellated for some reason"
								puts "==================================================================="
								return nil
							end
						end
					}
				end
			end

		else	# create a rectangle (as a Chipmunk Poly shape)
			poly = [CP::Vec2.new(-object.width/2.0, object.height/2.0), CP::Vec2.new(object.width/2.0, object.height/2.0), CP::Vec2.new(object.width/2.0, -object.height/2.0), CP::Vec2.new(-object.width/2.0, -object.height/2.0)] #, CP::Vec2.new(-object.width/2.0, object.height/2.0)]
			shapes << CP::Shape::Poly.new(body, poly, offset)		# NOTE: removed last vertex (see above)
		end

		puts "# NOTE: Tessellation of '#{object.options[:id]}' resulted in #{shapes.size} shapes!" if shapes.size > 1

		shapes.each { |shape| set_common_shape_properties(shape, object.options) }
		return shapes
	end

	def set_common_shape_properties(shape, options)
		# Map Feature: Elasticity and Friction of moveable objects
		shape.e = as_float(options[:elasticity], DEFAULT_ELASTICITY)
		shape.u = as_float(options[:friction], DEFAULT_FRICTION)

		# TODO 
		shape.layers = 0 if options[:collisions] == NO  # -- but some way that allows for constraints to find us via hit-
	end
end
