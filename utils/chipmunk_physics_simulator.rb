###############################################################################
#  Copyright 2011 Ian McIntosh <ian@openanswers.org>
###############################################################################

require 'set'
require 'chipmunk/lib/chipmunk'		# Docs: http://beoran.github.com/chipmunk/
puts "Using Chipmunk #{CP::VERSION}"

require 'chipmunk_addons'		# Our changes to the included objects

#
# Chipmunk helpers
#
require 'chipmunk_helpers'
require 'chipmunk_drawable_object'
require 'chipmunk_drawable_constraint'
require 'chipmunk_physical_object_collision_handler'
require 'chipmunk_trigger_collision_handler'
require 'chipmunk_spawner'
require 'chipmunk_drawable_group'
require 'chipmunk_drawable_static_list'

# TODO: comment
CP.collision_slop = 10

optional_require 'sound'

LUZ_ANGLE_TO_CHIPMUNK_ANGLE = (-2*Math::PI)

# Chipmunk physics
PHYSICS_RESOLUTION = 30
PHYSICS_TIME_DELTA = 1.0/150.0
IMPULSE_MODULATOR = (PHYSICS_RESOLUTION * PHYSICS_TIME_DELTA)

# Defaults 
DEFAULT_ANGLE_CONTROL_STIFFNESS = 10.0
DEFAULT_ANGLE_CONTROL_DAMPING = 0.2

# TODO: comment
DEFAULT_ELASTICITY = 0.0
DEFAULT_FRICTION = 1.0

DEFAULT_MOTOR_RATE = 1.0
DEFAULT_MOTOR_FORCE = 1.0

YES, NO = 'yes', 'no'		# avoids garbage production

#
# Resolving of values
#
def resolve_variable(var, default=0.5)
	var ? var.do_value : default
end

#
# Tesselation
#
RADIUS = 0.5		# create objects in a 1x1 space (scaleable later)
require 'gl_tessellator'

$gl_tessellator ||= GLTessellator.new
def render_filled_path(vertices, options)
	$gl_tessellator.render_filled_path(vertices, {:height => options[:height], :depth => options[:depth]})
end

class ChipmunkPhysicsSimulator
	include Drawing
	include Engine::MethodsForUserObject

	require 'chipmunk_render_helpers'
	include ChipmunkRenderHelpers

	require 'chipmunk_create_helpers'
	include ChipmunkCreateHelpers

	DEFAULT_SPRING_STIFFNESS = 10.0
	DEFAULT_SPRING_DAMPING = 0.1
	DEFAULT_ROTARY_SPRING_STIFFNESS = 0.1
	DEFAULT_ROTARY_SPRING_DAMPING = 0.1

	ControllableVector = Struct.new(:target, :variable_x, :low_x, :high_x, :variable_y, :low_y, :high_y, :proc)
	ControllableValue = Struct.new(:target, :variable, :low, :high, :proc)
	LinkedPair = Struct.new(:target, :other, :proc)
	ControllableObjectJump = Struct.new(:target, :event, :ray_distance, :ray_spread, :force, :proc)

	BreakableConstraint = Struct.new(:constraint, :force, :remaining, :sound, :sound_volume, :sound_pitch)

	CONSTRAINT_KEYS = [:motor, :pin, :joint, :winch, :spring, :gear]

	# object options that turn into fake button/slider input for Luz
	TRIGGER_BUTTONS = [:on_touch, :on_overlap, :on_overlap_all]
	TRIGGER_SLIDERS = [:slider_across_x, :slider_across_y]
	PHYSICAL_OBJECT_BUTTONS = [:on_touch]

	PHYSICAL_OBJECT_WITH_HANDLER_COLLISION_TYPE = :physical_object_with_handler
	PHYSICAL_OBJECT_NO_HANDLER_COLLISION_TYPE = :physical_object_no_handler

	WALL_NO_HANDLER_COLLISION_TYPE = :wall
	DEFAULT_WALL_ELASTICITY = 0.5
	DEFAULT_WALL_FRICTION = 0.5

	# Properties passed from a group to the drawables/shapes within
	GROUP_INHERITABLE_OPTIONS = Set.new([:render, :draw_method, :z, :height, :depth, :image, :elasticity, :friction, :collisions, :collision_type, :enter_time, :exit_time, :surface_velocity_x, :surface_velocity_y, :die_on_touch, :explosion_damage_multiplier])

	attr_reader :name, :parent

	def initialize(parent, name, options={})
		@parent, @name = parent, name

		@drawable_objects = []
		@updateables = []
		@static_path_segments = []

		@spawners_by_event = Hash.new { |hash, key| hash[key] = [] }
		@body_to_spawner = Hash.new { |hash, key| hash[key] = [] }

		@trigger_body_by_level_object = {}
		@breakable_constraints_by_event = Hash.new { |hash, key| hash[key] = [] }
		@breakable_constraints = []
		@trigger_collision_handlers = []
		@bodies_to_remove = Set.new
		@after_frame_procs = []
		@physical_object_collision_types_need_handler = {}
		@wall_collision_types_need_handler = {}
		@time_delta = 0.01 		# corrected by tick()
		@group_number_to_shapes = Hash.new { |hash, key| hash[key] = Set.new }

		@layer_static_body = CP::Body.new_static

		# Map Feature: 'scale', 'scale-x', 'scale-y' and 'z' for layers
		@scale_x, @scale_y = as_float(options[:scale_x], 1.0) * as_float(options[:scale], 1.0), as_float(options[:scale_y], 1.0) * as_float(options[:scale], 1.0)
		@translation_z = as_float(options[:z], 0.0)

		@layer_alpha = options[:fill_color].alpha
		@draw_method = as_draw_method(options[:draw_method])

		# Map Feature: 'render-actor' and 'render-effects' for layers
		@render_actor = find_actor_by_name(options[:render_actor] || options[:render_on_actor])		# still support old name
		@actor_effects = find_actor_by_name(options[:actor_effects])

		$engine.init_sound!
	end

	#
	# Helpers for the Chipmunk 'space'		http://beoran.github.com/chipmunk/#Space
	#
	def space
		@space ||= create_space
	end

	def remove_space
		@space = nil
	end

	#
	# Helpers for finding various created objects
	#
	def find_spawner_by_level_object(level_object)
		@spawners_by_event.each_pair { |event, spawners| spawners.each { |spawner| return spawner if spawner.object == level_object } }
		return nil
	end

	def find_trigger_body_by_level_object(level_object)
		@trigger_body_by_level_object[level_object]
	end

	#
	# Chipmunk 'group' releated helpers (group is an integer-- similar group numbers keeps shapes from colliding with each other) 
	#
	def get_next_group_id
		@next_group_id ||= 1
		@next_group_id += 1
	end

	def find_named_group(name)
		@named_groups ||= {}
		@named_groups[name] ||= get_next_group_id
	end

	#
	# Helpers for Chipmunk collision types
	#
	def add_collision_type_handler_info(object)
		needs_handler = PhysicalObjectCollisionHandler.object_needs_handler?(object)
		if object.options[:collision_type]
			shape_collision_type = make_collision_type_symbol(object.options[:collision_type])
		elsif needs_handler
			shape_collision_type = PHYSICAL_OBJECT_WITH_HANDLER_COLLISION_TYPE
		else
			shape_collision_type = PHYSICAL_OBJECT_NO_HANDLER_COLLISION_TYPE
		end
		@physical_object_collision_types_need_handler[shape_collision_type] ||= needs_handler
		shape_collision_type
	end

	#
	# Body finding helpers
	#
	def find_shapes_at_point(point)
		shapes = []
		space.point_query(point, CP::ALL_LAYERS, CP::NO_GROUP) { |shape| shapes << shape }
		shapes
	end

	def find_shapes_at_shape(shape)
		shapes = []
		space.shape_query(shape) { |s| shapes << s }
		shapes
	end

	def find_bodies_at_point(point)
		shapes = find_shapes_at_point(point)
		bodies = shapes.map { |shape| shape.body }
		bodies.uniq!
		bodies
	end

	def find_bodies_at_shape(shape)
		shapes = find_shapes_at_shape(shape)
		bodies = shapes.map { |shape| shape.body }
		bodies.uniq!
		bodies
	end

	# finds bodies at two points, ideally two different bodies, but will accept same or only 1 (other will be nil)
	def find_two_bodies(point_a, point_b)
		shapes_a = []
		space.point_query(point_a, CP::ALL_LAYERS, CP::NO_GROUP) { |shape| shapes_a << shape }
		bodies_a = shapes_a.map { |shape| shape.body }
		bodies_a.uniq!

		shapes_b = []
		space.point_query(point_b, CP::ALL_LAYERS, CP::NO_GROUP) { |shape| shapes_b << shape }
		bodies_b = shapes_b.map { |shape| shape.body }
		bodies_b.uniq!

		# Ideally find two distinct bodies
		bodies_a.each { |body_a|
			body_b = bodies_b.find { |bb| body_a != bb }
			return [body_a, body_b] if body_b
		}

		# Ultimately take anything, same bodies, nils
		return [bodies_a.first, bodies_b.first]		# might be nil
	end

	def with_env_for_actor(drawable)
		#
		# Here we are setting all the supported Object Variables and Object Events of the game plugin
		#
		body = drawable.body
		with_env(:child_index, drawable.child_index || 0) {
			# Map Feature: Enter / Exit for drawables
			enter = (drawable.entered_at.nil? or drawable.enter_time == 0.0) ? 1.0 : (($env[:time] - drawable.entered_at) / drawable.enter_time)
			exit = (drawable.exited_at.nil? or drawable.exit_time == 0.0) ? 0.0 : (($env[:time] - drawable.exited_at) / drawable.exit_time)
			with_enter_and_exit(enter, exit) {
				@parent.object_activation_variable_setting.with_value(drawable.activation) {
					return yield unless body		# other object Variables and Events are meaningless without a physical body

					speed_percentage = body.v.length / body.v_limit
					@parent.object_speed_variable_setting.with_value(speed_percentage) {
						rotation = (body.a / LUZ_ANGLE_TO_CHIPMUNK_ANGLE)
						rotation *= as_float(drawable.level_object.options[:rotation_variable_multiplier], 1.0)
						@parent.object_rotation_variable_setting.with_value(rotation % 1.0) {
							rotation_speed = (body.w.abs / body.w_limit)
							@parent.object_rotation_speed_variable_setting.with_value(rotation_speed) {
								@parent.object_sleeping_event_setting.with_value(body.sleeping?) {
									if drawable.takes_damage?
										@parent.object_damage_variable_setting.with_value(drawable.damage) {
											yield
										}
									else
										yield
									end
								}
							}
						}
					}
				}
			}
		}
	end

	#
	# create_object! is a convenience method that also adds object to @drawable_objects
	#
	def create_object!(object, body=nil, from_spawner=false)
		create_object(object, body, from_spawner) { |drawable|
			@drawable_objects << drawable
			yield drawable if block_given?
		}
	end

	#
	# Create Object -- the big one -- let's split this up at some point
	#
	def create_object(object, body=nil, from_spawner=false)
		#
		# If we're passed a body, any created shape will be added to it (otherwise we'll create a body)
		#
		use_parent_body = !body.nil?
		drawable = nil

		#
		# Process the collision-type now, so we get it for spawners, too.		TODO: move elsewhere?
		#
		shape_collision_type = add_collision_type_handler_info(object)

		# Investigate groups for custom collision types		TODO: move elsewhere?
		object.objects.each { |child_object| add_collision_type_handler_info(child_object) } if object.is_a? SVGLevelLoader::GroupObject

		# Create a Spawner (unless we're being called FROM a spawner!)
		if ((object.options[:spawner] == YES) && (from_spawner == false))
			if (event=find_event_by_name(object.options[:spawner_event]))
				spawner = Spawner.new(self, object)
				@spawners_by_event[event] << spawner

				# Create a DrawableObject that renders the spawner (which in turn renders all spawned objects)
				draw_proc = Proc.new { |drawable| spawner.render! }
				yield DrawableObject.new(self, body=nil, shapes=nil, shape_offset=nil, object, angle=nil, scale_x=nil, scale_y=nil, render_actor=nil, child_index=nil, draw_proc, fully_static=false)
			else
				puts "Failed to find event for spawner: #{object.options[:spawner_event]}"
			end
			return		# Spawner created. Don't continue to make an object now.
		end

		# Common properties, saved to DrawableObjects below
		child_index = as_integer(object.options[:child_number], 1) - 1
		angle = as_float(object.options[:angle], 0.0)
		scale_x = as_float(object.options[:scale_x], 1.0)
		scale_y = as_float(object.options[:scale_y], 1.0)

		# Map feature: 'image: file.png' (also handles drag'n'drop images in Inkscape)
		if object.options[:image].is_a? String
			object.options[:image] = $engine.load_images(object.options[:image]).first
		end

		render_actor = find_actor_by_name(object.options[:render_actor]) if object.options[:render_actor]
		actor_effects = find_actor_by_name(object.options[:actor_effects]) if object.options[:actor_effects]
		fully_static = false
		draw_proc = nil

		case object
		when SVGLevelLoader::RectObject
			#puts "Adding Rect object..."

			#
			# Create 'Massive' rectangles and static (infinite mass?) rectangles
			#
			if (object.options[:mass] or use_parent_body) or (object.options[:collisions] == YES) 		# Parent body has the mass
				#
				# Create Body and Shape for Rectangle
				#
				unless body
					if ((object.options[:collisions] == YES) and (use_parent_body == false))
						#
						# Create a static rectangle (harder to penetrate than a line loop)
						#
						body = CP::Body.new_static		# as it needs a custom position/rotation
						body.p = CP::Vec2.new(object.x, object.y)
						body.a = as_float(object.options[:angle]) * LUZ_ANGLE_TO_CHIPMUNK_ANGLE
						# NOTE: not adding to space.
						# TODO: if this doesn't need to be drawn, it doesn't need to be tracked at all (in @drawables or whatever)
					else
						mass = as_float(object.options[:mass])
						moment_of_inertia = CP.moment_for_box(mass, object.width, object.height) * as_float(object.options[:moment_of_inertia], 1.0)
						body = CP::Body.new(mass, moment_of_inertia)
						body.p = CP::Vec2.new(object.x, object.y)
						body.a = as_float(object.options[:angle]) * LUZ_ANGLE_TO_CHIPMUNK_ANGLE
						space.add_body(body)
					end
					body.drawables = []		# ruby binding data object, holds array of Drawables representing this body
				end

				offset = CP::Vec2.new(object.x, object.y) - body.p
				shapes = nil
				unless object.options[:collisions] == NO
					shapes = create_shapes_for_object(body, object, offset)
					return nil unless shapes
					shapes.each { |shape| space.add_shape(shape) }
				end

				#
				# Render Physical Rectangles
				#
				if object.options[:render] == NO
					# Map Feature: 'render: no'
				elsif render_actor
					draw_proc = method(:render_physical_rectangle_render_actor)
				elsif actor_effects
					render_actor = actor_effects		# store it in render_actor but we'll only use the effects
					draw_proc = method(:render_physical_rectangle_actor_effects)
				else
					# TODO: make walls unless collisions: no?
					fully_static = :partial
					draw_proc = method(:render_physical_filled_rectangle)
				end

				drawable = DrawableObject.new(self, body, shapes, offset, object, angle, scale_x, scale_y, render_actor, child_index, draw_proc, fully_static)
				body.drawables << drawable if body

			elsif (object.options.keys & [:pin, :motor, :spring]).empty? == false
				add_pin(object) if object.options[:pin] == YES
				add_motor(object) if object.options[:motor] == YES
				add_rotary_spring(object) if object.options[:spring] == YES

			else
				#
				# Render Non-Physical Rectangles
				#
				if object.options[:render] == NO
					# Map Feature: 'render: no'
				elsif render_actor
					draw_proc = method(:render_non_physical_rectangle_render_actor)
				elsif actor_effects
					render_actor = actor_effects		# store it in drawable.render_actor but we'll only use the effects
					draw_proc = method(:render_non_physical_rectangle_actor_effects)
				elsif as_float(object.options[:roll_rate], 0.0) != 0.0
					fully_static = :partial
					draw_proc = method(:render_static_rectangle_with_autoroll)
				else
					fully_static = true
					draw_proc = method(:render_static_rectangle)
				end

				drawable = DrawableObject.new(self, body=nil, shapes=nil, shape_offset=nil, object, angle, scale_x, scale_y, render_actor, child_index, draw_proc, fully_static)
				body.drawables << drawable if body
			end

		when SVGLevelLoader::PathObject
			#puts "Adding Path object..."
			is_closed = (object.vertices.first == object.vertices.last)

			if object.options[:mass] or use_parent_body		# Parent body has the mass
				if is_closed
					# Store these for use in create_shapes_for_object and the draw proc below
					object.options[:shape] = 'polygon'
					object.options[:shape_vertices] = object.vertices.map { |v| CP::Vec2.new(v.x - object.x, v.y - object.y) }.clean_vertex_list

					#
					# Create Polygon Body and Shape
					#
					unless body
						mass = as_float(object.options[:mass])
						moment_of_inertia = CP.moment_for_poly(mass, object.options[:shape_vertices], CP::ZERO_VEC_2) * as_float(object.options[:moment_of_inertia], 1.0)
						body = CP::Body.new(mass, moment_of_inertia)
						body.p = CP::Vec2.new(object.x, object.y)
						body.drawables = []
						space.add_body(body)
					end

					offset = CP::Vec2.new(object.x, object.y) - body.p
					shapes = nil
					unless object.options[:collisions] == NO
						shapes = create_shapes_for_object(body, object, offset)
						return nil unless shapes
						shapes.each { |shape| space.add_shape(shape) }
					end

					#
					# Render Physical Polygons
					#
					if object.options[:render] == NO
						# Map Feature: 'render: no'
					elsif render_actor
						draw_proc = method(:render_physical_polygon_with_render_actor)
					elsif actor_effects
						render_actor = actor_effects		# store it in render_actor but we'll only use the effects
						draw_proc = method(:render_physical_polygon_with_actor_effects)
					else
						fully_static = :partial
						draw_proc = method(:render_physical_polygon_filled)
					end

					drawable = DrawableObject.new(self, body, shapes, offset, object, angle, scale_x, scale_y, render_actor, child_index, draw_proc, fully_static)
					body.drawables << drawable if body

				else
					puts "error: #{object.options[:id]} has mass but is not closed"
				end

			elsif object.options[:spring] == YES or object.options[:gear] == YES or object.options[:winch] == YES
				# NOTE: can be both
				add_spring(object) if object.options[:spring] == YES
				add_winch(object) if object.options[:winch] == YES
				add_gear_joint(object) if object.options[:gear] == YES

			else
				# Map Feature: Paths without 'collisions: no' are collision segments 
				unless object.options[:collisions] == NO or object.options[:trigger] == YES
					add_wall(object)		# in additional to the visual representation below
				end

				if is_closed and object.options[:fill_color]
					object.options[:shape_vertices] = object.vertices

					#
					# Render non-physical Polygons
					#
					if object.options[:render] == NO
						# Map Feature: 'render: no'
					elsif render_actor
						draw_proc = method(:render_static_polygon_with_render_actor)
					elsif actor_effects
						render_actor = actor_effects		# store it in render_actor but we'll only use the effects
						draw_proc = method(:render_static_polygon_with_actor_effects)
					else
						fully_static = true
						draw_proc = method(:render_static_polygon)
					end

					drawable = DrawableObject.new(self, nil, nil, nil, object, angle, scale_x, scale_y, render_actor, child_index, draw_proc, fully_static)
					body.drawables << drawable if body
				end
			end

		when SVGLevelLoader::GroupObject
			#puts "Adding group #{object.options[:id]} with #{object.objects.count} objects..."
			children = object.objects

			# Copy inheritable properties to children 
			children.each { |child_object| child_object.options = object.options.reject { |name, value| !GROUP_INHERITABLE_OPTIONS.include?(name) }.merge(child_object.options) }

			if object.options[:mass]
				# Calculate center and bounding box for group
				average = CP::Vec2.new(0,0)
				min_x, max_x, min_y, max_y = CP::INFINITY, -CP::INFINITY, CP::INFINITY, -CP::INFINITY
				children.each { |child_object|
					average.x += child_object.x ; average.y += child_object.y
					min_x = (child_object.x - child_object.width/2) if (child_object.x - child_object.width/2) < min_x
					max_x = (child_object.x + child_object.width/2) if (child_object.x + child_object.width/2) > max_x
					min_y = (child_object.y - child_object.height/2) if (child_object.y - child_object.height/2) < min_y
					max_y = (child_object.y + child_object.height/2) if (child_object.y + child_object.height/2) > max_y
				}
				average /= children.count

				mass = as_float(object.options[:mass])
				moment_of_inertia = CP.moment_for_box(mass, max_x - min_x, max_y - min_y) * as_float(object.options[:moment_of_inertia], 1.0)
				body = CP::Body.new(mass, moment_of_inertia)
				body.p = CP::Vec2.new(average.x, average.y)

				body.drawables = []			# user data for the ruby bindings
				space.add_body(body)

				drawables = []
				children.each { |child_object|
					create_object(child_object, body, from_spawner) { |drawable| drawables << drawable }
				}

				# Create a DrawableGroup, if the class can handle these drawables
				#  (
				#
				if ENABLE_DRAWABLE_LIST_OPTIMIZATIONS and DrawableGroup.suitable?(drawables) 
					draw_proc = Proc.new { |drawable| drawable.render! }
					drawable = DrawableGroup.new(self, body, object, drawables, draw_proc)
					body.drawables << drawable
					# drawable is handled below
				else
					# Normal
					drawables.each { |drawable| yield drawable }
				end
			else
				# Groups without a mass are for organization, and...
				one_body = body		# possibly nil
				children.each { |child_object|
					create_object(child_object, body, from_spawner=false) { |drawable|		# note setting from_spawner false to allow spawner creation
						one_body ||= drawable.body
						yield drawable
					}
				}

				# ...tell any spawners made that they're body-relative, and...
				children.each { |child_object|
					if (child_object.options[:spawner] == YES and (spawner=find_spawner_by_level_object(child_object)))
						spawner.set_body_relative(one_body)
						@body_to_spawner[one_body] << spawner
					end
				} if one_body

				# ...tell any triggers made that they're body-relative
				children.each { |child_object|
					if (child_object.options[:trigger] == YES)
						# Triggers are setup last
						after_frame {		# TODO: change to after_init?
							if (trigger_body=find_trigger_body_by_level_object(child_object))
								update_proc = Proc.new { |updateable|
									updateable.other.p.x = updateable.target.p.x		# target is the source object
									updateable.other.p.y = updateable.target.p.y
								}
								@updateables << LinkedPair.new(target=one_body, other=trigger_body, update_proc)		# 
							end
						}
					end
				} if one_body
			end

		else
			raise "Unhandled Inkscape object: #{object.options[:id]}"
		end

		#
		# Set shape options
		#
		shapes.each { |shape|
			shape.level_object = object			# user data for the ruby bindings
			shape.collision_type = shape_collision_type
			shape.group = find_named_group(object.options[:no_collisions_group]) if object.options[:no_collisions_group]
		} if shapes

		#
		# Set body options (unless we've only created a shape for a parent body)
		#
		if body and use_parent_body == false
			# Map Feature: Persistent Force (eg. balloons)
			if object.options[:force_x] or object.options[:force_y]
				body.apply_force(CP::Vec2.new(as_float(object.options[:force_x]), as_float(object.options[:force_y])), CP::ZERO_VEC_2)
			end

			# Map Feature: Starting Velocity
			body.v = CP::Vec2.new(as_float(object.options[:velocity_x]), as_float(object.options[:velocity_y]))

			# Map Feature: Velocity Limit
			body.v_limit = as_float(object.options[:velocity_limit]) if object.options[:velocity_limit]

			# Map Feature: Rotational Force
			body.t = -as_float(object.options[:rotational_force])		# negated so positive = clockwise

			# Map Feature: Starting Rotation Velocity
			body.w = -as_float(object.options[:rotational_velocity])		# negated so positive = clockwise

			# Map Feature: Rotation Velocity Limit
			body.w_limit = as_float(object.options[:rotational_velocity_limit]) if object.options[:rotational_velocity_limit]

			# Control via Luz Events and Variables
			create_updateables_for_object(object, body, shapes, from_spawner)

			# Map Feature: 'follow: yes'
			@parent.add_follow_body(body) if object.options[:follow] == YES

			# Map Feature: Begin Sleeping
			body.sleep_alone if object.options[:sleeping] == YES
		end

		# For friendly editing, notify of any possible fake button presses
		PHYSICAL_OBJECT_BUTTONS.each { |button| $engine.new_button_notify_if_needed(object.options[button]) if object.options[button] } if $gui

		if drawable
			drawable.exit_time = as_float(object.options[:exit_time])
			drawable.sound_id = $sound.play(object.options[:looping_sound], :at => drawable.body.p, :volume => as_float(object.options[:looping_sound_volume], 1.0), :pitch => as_float(object.options[:looping_sound_pitch], 1.0), :looping => true, :fade_in => true) if ($sound and object.options[:looping_sound] and drawable.body)

			yield drawable
		end
	end

	#
	# Updateables (changes based on variables)
	#
	def create_updateables_for_object(object, body, shapes, from_spawner)
		# Map Feature: Rotational Velocity Control
		if object.options[:rotational_velocity_control_variable]
			update_proc = Proc.new { |updateable|
				if (amount = resolve_variable(updateable.variable).scale(updateable.low, updateable.high)) != 0.0
					updateable.target.activate			# in case it was sleeping
					updateable.target.w -= amount		# rotational velocity
				end
			}
			@updateables << ControllableValue.new(body,
				find_variable_by_name(object.options[:rotational_velocity_control_variable]), as_float(object.options[:rotational_velocity_control_min], -1.0), as_float(object.options[:rotational_velocity_control_max], 1.0),
				update_proc)
		end

		# Map Feature: Angle Control
		if object.options[:angle_control_variable]
			anchor_body = create_infinite_mass_body_at(body.p)		# doesn't matter where?
			spring_stiffness = DEFAULT_ANGLE_CONTROL_STIFFNESS * as_float(object.options[:angle_control_strength], 1.0)
			spring_damping = DEFAULT_ANGLE_CONTROL_DAMPING
			constraint = CP::Constraint::DampedRotarySpring.new(anchor_body, body, angle=0.0, spring_stiffness, spring_damping)
			add_constraint(constraint)

			update_proc = Proc.new { |updateable|
				amount = resolve_variable(updateable.variable).scale(updateable.low, updateable.high)
				updateable.target.a = (amount * LUZ_ANGLE_TO_CHIPMUNK_ANGLE)
			}
			@updateables << ControllableValue.new(anchor_body,
				find_variable_by_name(object.options[:angle_control_variable]), as_float(object.options[:angle_control_min], 0.0), as_float(object.options[:angle_control_max], 1.0),
				update_proc)
		end

		# Map Feature: Position Control X/Y			(NOTE: spawned objects can't be position controlled)
		if (from_spawner == false) and (object.options[:position_control_x_variable] or object.options[:position_control_y_variable])
			update_proc = Proc.new { |updateable|
				updateable.target.slew(CP::Vec2.new(resolve_variable(updateable.variable_x).scale(updateable.low_x, updateable.high_x), resolve_variable(updateable.variable_y).scale(updateable.low_y, updateable.high_y)), 0.2)		# 0.2 is a magic number that seems to feel right
			}
			@updateables << ControllableVector.new(body,
				find_variable_by_name(object.options[:position_control_x_variable]), body.p.x + as_float(object.options[:position_control_x_min], -0.5), body.p.x + as_float(object.options[:position_control_x_max], 0.5),
				find_variable_by_name(object.options[:position_control_y_variable]), body.p.y + as_float(object.options[:position_control_y_min], -0.5), body.p.y + as_float(object.options[:position_control_y_max], 0.5),
				update_proc)
		end

		# Map Feature: Force Control X/Y
		if (object.options[:force_control_x_variable] or object.options[:force_control_y_variable])
			update_proc = Proc.new { |updateable|
				force = CP::Vec2.new(resolve_variable(updateable.variable_x).scale(updateable.low_x, updateable.high_x), resolve_variable(updateable.variable_y).scale(updateable.low_y, updateable.high_y))
				if force != CP::ZERO_VEC_2
					updateable.target.activate															# in case it was sleeping
					updateable.target.apply_impulse(force * IMPULSE_MODULATOR, CP::ZERO_VEC_2)
				end
			}
			@updateables << ControllableVector.new(body,
				find_variable_by_name(object.options[:force_control_x_variable]), as_float(object.options[:force_control_x_min], -1.0), as_float(object.options[:force_control_x_max], 1.0),
				find_variable_by_name(object.options[:force_control_y_variable]), as_float(object.options[:force_control_y_min], -1.0), as_float(object.options[:force_control_y_max], 1.0),
				update_proc)
		end

		# Map Feature: Force Control Forward
		if (object.options[:force_control_forward_variable])
			update_proc = Proc.new { |updateable|
				if (amount = resolve_variable(updateable.variable).scale(updateable.low, updateable.high)) != 0
					#updateable.target.reset_forces														# clear last frame's force (NOTE that force isn't velocity, it's the object's own motor)
					updateable.target.activate			# in case it was sleeping
					force = CP::Vec2.new(0.0, amount).rotate(updateable.target.rot) * IMPULSE_MODULATOR
					updateable.target.apply_impulse(force, CP::ZERO_VEC_2)
				end
			}
			@updateables << ControllableValue.new(body,
				find_variable_by_name(object.options[:force_control_forward_variable]), as_float(object.options[:force_control_forward_min], -1.0), as_float(object.options[:force_control_forward_max], 1.0),
				update_proc)
		end

		# Map Feature: Rotational Velocity Control
		if object.options[:velocity_limit_variable]
			update_proc = Proc.new { |updateable|
				if (amount = resolve_variable(updateable.variable).scale(updateable.low, updateable.high)) != 0.0
					updateable.target.v_limit = amount		# rotational velocity
				end
			}
			@updateables << ControllableValue.new(body,
				find_variable_by_name(object.options[:velocity_limit_variable]), as_float(object.options[:velocity_limit_min], 0.0), as_float(object.options[:velocity_limit_max], 1.0),
				update_proc)
		end

		#
		# Map Feature: 'jump-event'
		#
		if (jump_event_name=object.options[:jump_event]) and (jump_event=find_event_by_name(jump_event_name))
			update_proc = Proc.new { |updateable|
				next unless updateable.event.now?
				object = updateable.target.drawables.first.level_object

				gravity_direction = space.gravity.normalize_safe
				from = updateable.target.p
				to = from + (gravity_direction * updateable.ray_distance)
				half_spread = ((to - from).perp.normalize * updateable.ray_spread) / 2
				filter_group = nil		#filter_group = updateable.level_object.group

				found_body = nil
				space.segment_query(from, to, CP::ALL_LAYERS, filter_group) { |shape, __t, __n|
					found_body = shape.body if (shape.sensor? == false and (filter_group.nil? or shape.group != filter_group))
				}
				space.segment_query(from + half_spread, to + half_spread, CP::ALL_LAYERS, filter_group) { |shape, __t, __n|
					found_body = shape.body if (shape.sensor? == false and (filter_group.nil? or shape.group != filter_group))
				} unless found_body
				space.segment_query(from - half_spread, to - half_spread, CP::ALL_LAYERS, filter_group) { |shape, __t, __n|
					found_body = shape.body if (shape.sensor? == false and (filter_group.nil? or shape.group != filter_group))
				} unless found_body

				# This appears to not filter out group...
				#			r = space.segment_query_first(from, to, CP::ALL_LAYERS, filter_group)
				#			r = space.segment_query_first(from + half_spread, to + half_spread, CP::ALL_LAYERS, filter_group)
				#			l = space.segment_query_first(from - half_spread, to - half_spread, CP::ALL_LAYERS, filter_group)

				if found_body
					# play jump sound
					updateable.target.activate		# in case it was sleeping
					updateable.target.apply_impulse(-gravity_direction * updateable.force, CP::ZERO_VEC_2)
					found_body.activate		# in case it was sleeping
					found_body.apply_impulse(-gravity_direction * -updateable.force, to - found_body.p)

					jump_sound = object.options[:jump_sound]
					$sound.play(jump_sound, :volume => object.options[:jump_sound_volume], :pitch => object.options[:jump_sound_pitch], :at => body.p) if $sound and jump_sound
				else
					# play jump failed sound
				end
			}

			shape = shapes.first		# hack after move to multi-shape yield create_shapes_for_object
			height = (shape.bb.b-shape.bb.t).abs
			width = (shape.bb.r-shape.bb.l).abs

			@updateables << ControllableObjectJump.new(body, jump_event,
				(height*0.5) * as_float(object.options[:jump_ray_distance], 1.0),
				(width*0.5) * as_float(object.options[:jump_ray_spread], 1.0),
				as_float(object.options[:jump_force], 0.1),
				update_proc)
		end
	end

	def process_updateables
		@updateables.each { |updateable| updateable.proc.call(updateable) }
	end

	# There are potentially many updates for a given target (target is the object whose properties are being controller, usually a CP::Shape or CP::Body)
	def remove_updateable_target(target)
		@updateables.delete_if { |u| u.target == target }
	end

	#
	# Group numbering
	#
	def harmonize_group_numbers(shapes)
		#
		# Find all shapes on the same bodies, and collect group_ids
		#
		used_group_ids = []
		all_shapes = Set.new
		shapes.each { |shape|
			# Interrogate all shapes of this body
			shape.body.drawables.each { |drawable|
				if drawable.shapes
					drawable.shapes.each { |shape| 
						all_shapes << shape
						used_group_ids << shape.group if shape.group
					}
				end
			}
			# assert(all_shapes.include?(shape))
		}

		if used_group_ids.empty?
			#puts "groups empty"
			group_id = get_next_group_id
		else
			# TODO: pick the most common?
			#puts "picking from among #{used_group_ids.size} group ids: #{used_group_ids.sort.join(', ')}"
			group_id = used_group_ids.first
		end

		# Apply new group id
		all_shapes.each { |shape|
			if shape.group and shape.group != group_id
				# if we're moving one shape to a new group, we move ALL shapes (ie all 6s) to the new group number
				#assert @group_number_to_shapes[shape.group]
				#puts "mass moving #{@group_number_to_shapes[shape.group].size} shapes from group #{shape.group} to #{group_id}"
				@group_number_to_shapes[shape.group].each { |sibling_shape|
					#assert_equal shape.group, sibling_shape.group
					sibling_shape.group = group_id
					@group_number_to_shapes[group_id] << sibling_shape
				}
				@group_number_to_shapes.delete(shape.group)
			end
			#puts "assigning shape#{shape.level_object.options[:id]} to group #{group_id}"
			@group_number_to_shapes[group_id] << shape
			shape.group = group_id
		}
	end

	def group_numbers_remove_shape(shape)
		@group_number_to_shapes[shape.group].delete(shape) if shape.group
	end

	#
	# Collisions
	#
	def create_collision_callbacks
		physical_object_collision_handler = PhysicalObjectCollisionHandler.new(self)
		physical_object_collision_handler_with_presolve = PhysicalObjectCollisionHandlerWithPreSolve.new(self)

		#puts "=== Creating Active vs Active Collision Pairs ==="
		active_list = @physical_object_collision_types_need_handler.keys
		active_list.each { |a|
			# Add a vs a, and a vs basic wall
			if @physical_object_collision_types_need_handler[a]
				#puts "add handler : #{a} vs #{a}"
				# Objects of same type
				@space.add_collision_handler(a, a, physical_object_collision_handler)

				# Object vs generic walls
				@space.add_collision_handler(a, WALL_NO_HANDLER_COLLISION_TYPE, physical_object_collision_handler)
			else
				#puts "skip handler: #{a} vs #{a}"
			end
		}
		active_list.each_pair { |a, b|
			# does either type need a collision handler?
			if (@physical_object_collision_types_need_handler[a] or @physical_object_collision_types_need_handler[b])
				#puts "add handler : #{a} vs #{b}"
				@space.add_collision_handler(a, b, physical_object_collision_handler)
			else
				#puts "skip handler: #{a} vs #{b}"
			end
		}

		#puts "=== Creating Active vs Static Collision Pairs ==="
		static_list = @wall_collision_types_need_handler.keys
		static_list.each { |static_type|
			# a wall that reacts-- needs collision handler vs ALL moving types
			case @wall_collision_types_need_handler[static_type]
			when false
				# already has a handler for generic WALL_NO_HANDLER_COLLISION_TYPE above
			when true
				active_list.each { |active_type|
					#puts "add handler : #{static_type} vs #{active_type}"
					@space.add_collision_handler(static_type, active_type, physical_object_collision_handler)
				}
			when :pre_solve
				active_list.each { |active_type|
					#puts "add handler : #{static_type} vs #{active_type} (no presolve)"
					@space.add_collision_handler(static_type, active_type, physical_object_collision_handler_with_presolve)
				}
			else
				raise "unhandled @wall_collision_types_need_handler value: #{@wall_collision_types_need_handler[static_type]}"
			end
		}
	end

	#
	# Triggers
	#
	def add_trigger(object)
		collision_type = object.options[:id]		# use the 'id' string as the collision type, making the callback unique to this trigger

		collides_with = []
		if object.options[:collides_with]
			object.options[:collides_with].split(',').each { |type_string|
				collides_with << make_collision_type_symbol(type_string)
			}
		else
			collides_with = @physical_object_collision_types_need_handler.keys
			#puts "adding trigger for #{object.options[:id]} that collides with all known types"
		end

		body = create_infinite_mass_body_at(CP::Vec2.new(object.x,  object.y))
		@trigger_body_by_level_object[object] = body

		#
		# Create a Shape
		#
		shapes = create_shapes_for_object(body, object)
		shape = shapes.first
		shape.sensor = true		# Don't generate physics collisions, don't match point_query_first()
		shape.collision_type = collision_type
		space.add_shape(shape)

		# Each trigger gets its own handler object (used for all its collides-with, though)
		if TriggerCollisionOverlapHandler.object_requires_overlap_handler?(object)
			trigger_collision_handler = TriggerCollisionOverlapHandler.new(self, object)
		else
			trigger_collision_handler = TriggerCollisionHandler.new(self, object)
		end
		collides_with.each { |collides_with_type|
			#puts "adding trigger handler: #{collision_type} vs #{collides_with_type}"
			space.add_collision_handler(collision_type, collides_with_type, trigger_collision_handler)
		}

		@trigger_collision_handlers << trigger_collision_handler

		# This auto-fills GUI lists with possible on-touch button presses when loading levels
		TRIGGER_BUTTONS.each { |key| $engine.new_button_notify_if_needed(object.options[key]) if object.options[key] }
		TRIGGER_SLIDERS.each { |key| $engine.new_slider_notify_if_needed(object.options[key]) if object.options[key] }

		# Map Feature: Slider Across 
		$engine.new_slider_notify_if_needed(object.options[:slider_across_x]) if object.options[:slider_across_x]
		$engine.new_slider_notify_if_needed(object.options[:slider_across_y]) if object.options[:slider_across_y]
	end

	#
	# Helpers for adding physics objects and constraints
	#
	def add_rotary_spring(object)
		anchor_point = CP::Vec2.new(object.x, object.y)
		shapes = []
		space.point_query(anchor_point, CP::ALL_LAYERS, CP::NO_GROUP) { |shape| shapes << shape }
		bodies = shapes.map { |shape| shape.body }
		bodies.uniq!

		if bodies.size == 1
			#puts "add_rotary_spring(1) for #{object.options[:id]}"
			body_a = bodies.first
			anchor_body = create_infinite_mass_body_at(anchor_point)
			add_constraint(CP::Constraint::PinJoint.new(body_a, anchor_body, anchor_point - body_a.p, CP::ZERO_VEC_2))

			spring_stiffness, spring_damping = DEFAULT_ROTARY_SPRING_STIFFNESS * as_float(object.options[:spring_stiffness], 1.0), DEFAULT_ROTARY_SPRING_DAMPING * as_float(object.options[:spring_damping], 1.0)
			spring = CP::Constraint::DampedRotarySpring.new(anchor_body, body_a, restAngle=0, spring_stiffness, spring_damping)
			add_constraint(spring)

		elsif bodies.size == 2 and shapes.size == 2
			#puts "add_rotary_spring(2) (id #{object.options[:id]})"

			#group = shapes.first.group || shapes.last.group || get_next_group_id
			harmonize_group_numbers(shapes)
			#shapes.first.group = shapes.last.group = group
			add_constraint(CP::Constraint::PinJoint.new(bodies.first, bodies.last, anchor_point - bodies.first.p, anchor_point - bodies.last.p))

			#angle = ((bodies.first.p - bodies.last.p).to_angle)
			# maintain present angle between bodies, as found by the dot product of the vectors V from anchor_point to bodies
			#angle = (bodies.last.p - anchor_point).to_angle - (bodies.first.p - anchor_point).to_angle
			
			# TODO: is dot product right for this ?  seems to work OK
			angle = (bodies.first.p - anchor_point).dot(bodies.last.p - anchor_point)
			#puts "original rest angle: #{angle} (luz angle: #{angle / LUZ_ANGLE_TO_CHIPMUNK_ANGLE})"
			#rest_angle = (angle % (2*3.1415))
			rest_angle = (angle >= 0.0) ? (angle % (2*Math::PI)) : -(-angle % (2*Math::PI))

			spring_stiffness, spring_damping = DEFAULT_ROTARY_SPRING_STIFFNESS * as_float(object.options[:spring_stiffness], 1.0), DEFAULT_ROTARY_SPRING_DAMPING * as_float(object.options[:spring_damping], 1.0)
			add_constraint(CP::Constraint::DampedRotarySpring.new(bodies.first, bodies.last, rest_angle, spring_stiffness, spring_damping))

		else
			puts "error: spring #{object.options[:id]} overlaps with #{shapes.size} objects, must be 1 or 2"
		end
	end

	def add_gear_joint(object)
		options, vertex_list = object.options, object.vertices

		if vertex_list.length == 2
			a, b = vertex_list.first, vertex_list.last

			shape_a = space.point_query_first(a, CP::ALL_LAYERS, CP::NO_GROUP)
			shape_b = space.point_query_first(b, CP::ALL_LAYERS, CP::NO_GROUP)

			if shape_a and shape_b
				phase, ratio = 0, as_float(object.options[:gear_ratio], 1.0)
				add_constraint(CP::Constraint::GearJoint.new(shape_a.body, shape_b.body, phase, ratio))
			else
				puts "gear joint setup failed: not touching two objects"
			end
		else
			puts "gear joint setup failed: path has more than 2 vertices"
		end
	end

	SEGMENT_WIDTH = 0.001		# wider seems to cause objects to stick in ground
	def add_wall(object)
		options, vertex_list = object.options, object.vertices

		if PhysicalObjectCollisionHandler.object_needs_handler?(object)
			collision_type = object.options[:id].to_sym		# a unique collision type for these segments
			if PhysicalObjectCollisionHandler.object_needs_pre_solve_handler?(object)
				@wall_collision_types_need_handler[collision_type] = :pre_solve
			else
				@wall_collision_types_need_handler[collision_type] = true
			end
		else
			collision_type = WALL_NO_HANDLER_COLLISION_TYPE
			@wall_collision_types_need_handler[collision_type] = false
		end

		vertex_list.each_cons(2) { |a, b|
			shape = CP::Shape::Segment.new(@layer_static_body, a, b, SEGMENT_WIDTH)
			shape.level_object = object
			shape.collision_type = collision_type
			shape.surface_v = CP::Vec2.new(as_float(options[:surface_velocity_x], 0.0), as_float(options[:surface_velocity_y], 0.0))
			shape.e = as_float(options[:elasticity], DEFAULT_WALL_ELASTICITY)
			shape.u = as_float(options[:friction], DEFAULT_WALL_FRICTION)
			space.add_static_shape(shape)
			@static_path_segments << [a, b]		# for debug drawing
		}
	end

	DEFAULT_WINCH_LENGTH = 1.0		# multiples of drawn segment's length
	CHIPMUNK_DEFAULT_BIAS_COEF = 0.1

	def add_winch(object)
		options, vertex_list = object.options, object.vertices
		return puts "winch #{object.options[:id]} setup failed: path has #{vertex_list.length} vertices, must be 2" if vertex_list.length > 2

		point_a, point_b = vertex_list.first, vertex_list.last
		body_a, body_b = find_two_bodies(point_a, point_b)
		return puts "winch #{object.options[:id]} can't find any bodies" unless (body_a or body_b)

		body_a ||= create_infinite_mass_body_at(point_a)
		body_b ||= create_infinite_mass_body_at(point_b)

		constraint = nil

		winch_length_min = as_float(object.options[:winch_length_min], 0.0)
		winch_length_max = as_float(object.options[:winch_length_max], 1.0)
		winch_length = (DEFAULT_WINCH_LENGTH).clamp(winch_length_min, winch_length_max)

		drawn_length = (point_b - point_a).length
		starting_length = drawn_length * winch_length

		min_length = drawn_length * winch_length_min
		max_length = drawn_length * winch_length_max

		# The absolute limits
		constraint = CP::Constraint::SlideJoint.new(body_a, body_b, point_a - body_a.p, point_b - body_b.p, min_length, max_length)
		add_constraint(constraint)

		# The controllable one
		constraint = CP::Constraint::SlideJoint.new(body_a, body_b, point_a - body_a.p, point_b - body_b.p, starting_length, starting_length)
		winch_force = as_float(object.options[:winch_force], 1.0)
		constraint.max_force = winch_force	# max_force= INFINITY the maximum force that the constraint can use to act on the two bodies. Defaults to INFINITY.
		winch_speed = as_float(object.options[:winch_speed], 1.0)
		constraint.max_bias = winch_speed		# max_bias= INFINITY the maximum speed at which the constraint can apply error correction.
		add_constraint(constraint)

		# bias_coef= <float> Defaults to 0.1. the percentage of error corrected each step of the space. (Can cause issues if you don’t use a constant time step) 

		#
		# Map Feature: 'winch-length-variable'
		#
		if (variable=find_variable_by_name(object.options[:winch_length_variable]))
			update_proc = Proc.new { |updateable|
				if (amount = resolve_variable(updateable.variable).scale(updateable.low, updateable.high)) != 0.0
					updateable.target.min = amount
					updateable.target.max = amount
				end
			}
			@updateables << ControllableValue.new(constraint, variable, min_length, max_length, update_proc)
		end

		draw_proc = method(:render_spring)
		@drawable_objects << DrawableConstraint.new(self, constraint, object, render_actor=nil, draw_proc, fully_static=false) if object.options[:render] == YES

		# TODO breakable? => using 'impulse'
	end

	def add_spring(object)
		options, vertex_list = object.options, object.vertices
		return puts "spring #{object.options[:id]} setup failed: path has #{vertex_list.length} vertices, must be 2" if vertex_list.length > 2

		point_a, point_b = vertex_list.first, vertex_list.last
		body_a, body_b = find_two_bodies(point_a, point_b)
		return puts "spring #{object.options[:id]} can't find any bodies" unless (body_a or body_b)

		body_a ||= create_infinite_mass_body_at(point_a)
		body_b ||= create_infinite_mass_body_at(point_b)

#		drawn_length = (point_b - point_a).length
#		starting_length = drawn_length * winch_length

		drawn_length = ((point_a) - (point_b)).length
		spring_length = drawn_length * as_float(options[:spring_length], 1.0)		# current length
		spring_stiffness, spring_damping = DEFAULT_SPRING_STIFFNESS * as_float(options[:spring_stiffness], 1.0), DEFAULT_SPRING_DAMPING * as_float(options[:spring_damping], 1.0)

		if object.options[:spring_segments] and (segment_count=as_integer(object.options[:spring_segments], 1)) and segment_count > 1
			segment_length = (spring_length / segment_count)
			direction = (point_b - point_a).normalize_safe

			# create segments
			tmp_a, tmp_b = body_a, nil
			for i in (1..segment_count)
				point_b = point_a + (direction * segment_length)
				tmp_b = CP::Body.new(0.001, 0.001)
				space.add_body(tmp_b)
				spring = CP::Constraint::DampedSpring.new(tmp_a, tmp_b, (point_a - tmp_a.p), (point_b - tmp_b.p), segment_length, spring_stiffness, spring_damping)
				#spring.max_force = 0.01
				add_constraint(spring)
				tmp_a, point_a = tmp_b, point_b

				draw_proc = method(:render_spring)
				@drawable_objects << DrawableConstraint.new(self, constraint=spring, object, render_actor=nil, draw_proc, fully_static=false) unless object.options[:render] == NO
			end
			spring = CP::Constraint::DampedSpring.new(tmp_a, body_b, (point_a - tmp_a.p), (point_b - body_b.p), segment_length, spring_stiffness, spring_damping)
			add_constraint(spring)
		else
			spring = CP::Constraint::DampedSpring.new(body_a, body_b, (point_a - body_a.p), (point_b - body_b.p), spring_length, spring_stiffness, spring_damping)
			add_constraint(spring)
		end

		# TODO: does this belong here??  what about multisegment springs
		draw_proc = method(:render_spring)
		@drawable_objects << DrawableConstraint.new(self, constraint=spring, object, render_actor=nil, draw_proc, fully_static=false) unless object.options[:render] == NO
	end

	def add_pin(object)
		anchor_point = CP::Vec2.new(object.x, object.y)
		shapes = []
		space.point_query(anchor_point, CP::ALL_LAYERS, CP::NO_GROUP) { |shape| shapes << shape }

		bodies = shapes.map { |shape| shape.body }
		bodies.uniq!

		angle_limit_min, angle_limit_max = object.options[:angle_limit_min], object.options[:angle_limit_max]

		pins = []
		if bodies.size == 1
			body_a = bodies.first
			static_body = create_infinite_mass_body_at(anchor_point)
			pin = CP::Constraint::PinJoint.new(body_a, static_body, anchor_point - body_a.p, CP::ZERO_VEC_2)
			add_constraint(pin)

			# TODO: is dot product right for this ?  seems to work OK
			#puts "original rest angle: #{angle} (luz angle: #{angle / LUZ_ANGLE_TO_CHIPMUNK_ANGLE})"
			#rest_angle = (angle % (2*3.1415))
			#rest_angle = (angle >= 0.0) ? (angle % (2*Math::PI)) : -(-angle % (2*Math::PI))

			if angle_limit_min || angle_limit_max
				angle = (bodies.first.p - anchor_point).dot(bodies.last.p - anchor_point)
				constraint = CP::Constraint::RotaryLimitJoint.new(body_a, static_body, angle + (as_float(angle_limit_min, 0.0) * -LUZ_ANGLE_TO_CHIPMUNK_ANGLE), angle + (as_float(angle_limit_max, 0.0) * -LUZ_ANGLE_TO_CHIPMUNK_ANGLE))
				add_constraint(constraint)
			end
			pins << pin
		else
			harmonize_group_numbers(shapes)
			shapes.each_cons(2) { |a, b|
				next if a.body == b.body		# don't pin within the same rigid body!
				pin = CP::Constraint::PinJoint.new(a.body, b.body, anchor_point - a.body.p, anchor_point - b.body.p)
				add_constraint(pin)
				if angle_limit_min || angle_limit_max
					angle = (a.body.p - anchor_point).dot(b.body.p - anchor_point)
					constraint = CP::Constraint::RotaryLimitJoint.new(a.body, b.body, angle + (as_float(angle_limit_min, 0.0) * -LUZ_ANGLE_TO_CHIPMUNK_ANGLE), angle + (as_float(angle_limit_max, 0.0) * -LUZ_ANGLE_TO_CHIPMUNK_ANGLE))
					add_constraint(constraint)
				end
				pins << pin
			}
		end

		# Map Feature: event- and force-breakable pins
		pins.each { |pin|
			@breakable_constraints_by_event[object.options[:break_on_event]] << BreakableConstraint.new(pin, force=nil, as_integer(object.options[:break_on_event_count]), object.options[:on_break_sound], as_float(object.options[:on_break_sound_volume], 1.0), as_float(object.options[:on_break_sound_pitch], 1.0)) if object.options[:break_on_event]
			@breakable_constraints << BreakableConstraint.new(pin, as_float(object.options[:break_on_force], 0.01), as_integer(object.options[:break_on_force_count], 1), object.options[:on_break_sound], as_float(object.options[:on_break_sound_volume], 1.0), as_float(object.options[:on_break_sound_pitch], 1.0)) if object.options[:break_on_force]
		}
	end

	def add_motor(object)
		anchor_point = CP::Vec2.new(object.x, object.y)
		bodies = find_bodies_at_point(anchor_point)
		return puts "error: motor overlaps with #{bodies.size} objects, must be 1 or more" if bodies.empty?

		motor_rate = (DEFAULT_MOTOR_RATE * as_float(object.options[:motor_rate], 1.0))
		motor_rate = motor_rate.clamp(as_float(object.options[:motor_rate_min], motor_rate), as_float(object.options[:motor_rate_max], motor_rate))

		motor_max_force = (DEFAULT_MOTOR_FORCE * as_float(object.options[:motor_force], 1.0))
		motor_max_force = motor_rate.clamp(as_float(object.options[:motor_force_min], motor_max_force), as_float(object.options[:motor_force_max], motor_max_force))

		# Add a motor for each body
		motors = []
		if object.options[:pin] || bodies.size == 1
			# Attach each body to infinite mass object
			anchor_body = create_infinite_mass_body_at(anchor_point)
			bodies.each { |body|
				motors << CP::Constraint::SimpleMotor.new(anchor_body, body, motor_rate)
			}
		else
			# Attach each body to its neighbor
			bodies.each_cons(2) { |a, b|
				motors << CP::Constraint::SimpleMotor.new(a, b, motor_rate)
			}
		end

		motors.each { |motor|
			#
			# Map Feature: 'motor-rate-variable'
			#
			if (variable=find_variable_by_name(object.options[:motor_rate_variable]))
				update_proc = Proc.new { |updateable|
					amount = resolve_variable(updateable.variable).scale(updateable.low, updateable.high)
					updateable.target.rate = (DEFAULT_MOTOR_RATE * amount)
				}
				@updateables << ControllableValue.new(motor,
					variable, as_float(object.options[:motor_rate_min], 0.0), as_float(object.options[:motor_rate_max], 1.0),
					update_proc)
			end

			#
			# Map Feature: 'motor-force'	(static force setting)
			#
			motor.max_force = motor_max_force		# TODO: what metric is this in??

			#
			# Map Feature: 'motor-force-variable' (dynamic force setting)
			#
			if (variable=find_variable_by_name(object.options[:motor_force_variable]))
				update_proc = Proc.new { |updateable|
					if (amount = resolve_variable(updateable.variable).scale(updateable.low, updateable.high)) != 0.0
						updateable.target.max_force = (DEFAULT_MOTOR_FORCE * amount)
					end
				}
				@updateables << ControllableValue.new(motor,
					find_variable_by_name(object.options[:motor_force_variable]), as_float(object.options[:motor_force_min], 0.0), as_float(object.options[:motor_force_max], 1.0),
					update_proc)
			end

			add_constraint(motor)
		}
	end

	def add_constraint(constraint)
		@space.add_constraint(constraint)
		constraint.body_a.add_constraint(constraint)
		constraint.body_b.add_constraint(constraint)
	end

	#
	# Feature: queue callbacks for after frame rendering (for tasks that can't happen immediately)
	#
	def after_frame(&proc)
		@after_frame_procs << proc
	end

	def call_after_frame_procs
		@after_frame_procs.each { |proc| proc.call }
		@after_frame_procs.clear
	end

	def wake_up_sleeping_bodies
		# Used only to circumvent a chipmunk 'bug' when gravity changes and objects don't respond because they're sleeping
		#t = Time.new.to_f
		@huge_shape ||= CP::Shape::Circle.new(@layer_static_body, 5.0, CP::ZERO_VEC_2)
		@space.activate_touching(@huge_shape)
		#puts "wakeup took #{Time.new.to_f - t}" 
	end

	def tick(speed_of_time, gravity_x, gravity_y, damping)
		return unless @space		# nothing to do for layers without physics

		time_delta = (PHYSICS_TIME_DELTA * speed_of_time)

		@time_delta = time_delta
		if (@space.gravity.x != gravity_x) or (@space.gravity.y != gravity_y)
			# A hack to wake up sleeping objects when gravity changes
			# The rule below may not be comprehensive enough
			wake_up_sleeping_bodies if (((@space.gravity.x <= 0.0) and (gravity_x > 0.0)) or ((@space.gravity.x >= 0.0) and (gravity_x < 0.0)) or ((@space.gravity.y <= 0.0) and (gravity_y > 0.0)) or ((@space.gravity.y >= 0.0) and (gravity_y < 0.0)))
			@space.gravity.x, @space.gravity.y = gravity_x, gravity_y
		end
		@space.damping = damping

		if ($env[:enter] == 1.0) && ($env[:exit] == 0.0)
			# Spawners
			tick_spawners!

			# Breakable constraints
			tick_breakable_constraints!
		end

		# Updateables
		process_updateables

		# Physics Simulation
		PHYSICS_RESOLUTION.times { @space.step(@time_delta) }

		# Check Constraints for breakage		TODO: must this be done after each step?
		@breakable_constraints.delete_if { |breakable_constraint|
			force = (breakable_constraint.constraint.impulse / @time_delta)		# TODO: this probably isn't the right divisor?
			breakable_constraint.remaining -= 1 if force > breakable_constraint.force
			if breakable_constraint.remaining == 0
				$sound.play(breakable_constraint.sound, :volume => breakable_constraint.sound_volume, :pitch => breakable_constraint.sound_pitch, :at => breakable_constraint.constraint.body_a.p) if $sound and breakable_constraint.sound
				@space.remove_constraint(breakable_constraint.constraint)
				true
			else
				false
			end
		}
	end

	def tick_spawners!
		spawners_to_activate = nil		# This is necessary because we can't add to @spawners_by_event while iterative over it-- ie spawning spawners (eg. ships with guns)
		@spawners_by_event.each_pair { |event, spawners|
			next unless event.now?
			spawners_to_activate ||= []		# avoid creating array unless needed
			spawners_to_activate.concat(spawners)
		}
		spawners_to_activate.each { |spawner| spawner.spawn! }.clear if spawners_to_activate
	end

	def tick_breakable_constraints!
		@breakable_constraints_by_event.each_pair { |event_title, breakable_constraints|
			next unless (event=find_event_by_name(event_title) and event.now?)
			breakable_constraints.delete_if { |breakable_constraint|
				if (breakable_constraint.remaining -= 1) <= 0
					$sound.play(breakable_constraint.sound, :volume => breakable_constraint.sound_volume, :pitch => breakable_constraint.sound_pitch, :at => breakable_constraint.constraint.body_a.p) if $sound and breakable_constraint.sound
					@space.remove_constraint(breakable_constraint.constraint)
					true
				else
					false
				end
			}
		}
	end

	#
	# Rendering 
	#
	def render!(debug_render=false)
		# This is rendering of one layer of a level
		if @render_actor
			with_offscreen_buffer { |buffer|
				# Render to offscreen
				aspect_scale = $env[:aspect_scale]
				buffer.using {
					with_layer_positioning {
						if aspect_scale
							# make sure our 1x1 shape fills screen by rendering smaller... 
							with_scale(1.0/aspect_scale, 1.0/aspect_scale) {
								render_with_layer_options
								render_paths if debug_render
							}
						else
							render_with_layer_options
							render_paths if debug_render
						end
					}
				}
				# Render actor with image of rendered scene as default Image
				buffer.with_image {
					if aspect_scale
						# ...and scaling larger on display
						with_scale(aspect_scale, aspect_scale) {
							@render_actor.render!
						}
					else
						@render_actor.render!
					end
				}
			}

		elsif @actor_effects
			with_layer_positioning {
				@actor_effects.render_recursive {
					render_with_layer_options
					render_paths if debug_render
				}
			}

		else
			with_layer_positioning {
				render_with_layer_options
				render_paths if debug_render
			}
		end
		call_after_frame_procs unless @after_frame_procs.empty?
	end

	def with_layer_positioning
		# Apply parent positioning (camera etc.) then layer positioning options
		@parent.with_layer_positioning {
			with_translation(0.0, 0.0, @translation_z) {
				with_scale_unsafe(@scale_x, @scale_y) {
					yield
				}
			}
		}
	end

private

	def render_with_layer_options
		with_multiplied_alpha(@layer_alpha) {
			with_pixel_combine_function(@draw_method) {
				render_prune_drawables(@drawable_objects)
			}
		}
	end

	def render_paths
		@static_paths_display_list = GL.RenderCached(@static_paths_display_list) {
			GL.Begin(GL::LINES)
			@static_path_segments.each { |path|
				GL.Vertex(path.first.x, path.first.y)
				GL.Vertex(path.last.x, path.last.y)
			}
			GL.End
		}
	end

public

	def remove_spawner(spawner)
		@spawners_by_event.each_pair { |event, array| array.delete(spawner) }		# TODO: faster
		spawner.shutdown!
	end

	def remove_spawners_for_body(body)
		return unless @body_to_spawner.include? body
		@body_to_spawner[body].each { |spawner| remove_spawner(spawner) }
		@body_to_spawner[body].clear
	end

	# MOVEME to Drawable
	def remove_drawable_body(drawable)
		@parent.follow_bodies.delete(drawable.body)
		remove_updateable_target(drawable.body)
		drawable.body.constraints.delete_if { |constraint| @space.remove_constraint(constraint) ; true }		# TODO: OK to multi-remove (from both bodies), I think?
		remove_spawners_for_body(drawable.body)
		remove_shapes_from_drawable(drawable)
		@space.remove_body(drawable.body) if (drawable.body && drawable.exit_still?)				# TODO: does this properly handle multiple drawables per body???
	end

	def remove_shapes_from_drawable(drawable)
		drawable.each_shape { |shape|
			@space.remove_shape(shape)
			remove_updateable_target(shape)
			group_numbers_remove_shape(shape)
		}
		drawable.shapes = nil
	end

	def render_prune_drawables(drawables)
		now = $env[:time]

		drawables.delete_if { |drawable|
			# Remove from physical world?
			remove_drawable_body(drawable) if @bodies_to_remove.delete?(drawable.body)

			# Has it finished exit animation?
			if (drawable.exited_at and ((now - drawable.exited_at) >= drawable.exit_time))
				@space.remove_body(drawable.body)		# for sure and for good!!
				drawable.finalize!
				true		# remove completely
			else
				# Begin scheduled exit?
				if (drawable.scheduled_exit_at && drawable.exited_at.nil? && (now >= drawable.scheduled_exit_at))
					# Can't call exit_drawable during render_prune, so we delay it
					after_frame { exit_drawable(drawable) }
				end

				#
				# normal rendering
				#
				drawable.update!
				drawable.render!

				false		# keep
			end
		}
	end

	def explosion_at(point, radius, force, damage_amount, exclude_body=nil)
		shape = CP::Shape::Circle.new(@layer_static_body, radius, point)
		bodies = find_bodies_at_shape(shape)
		bodies.delete(exclude_body)
		bodies.each { |body|
			vector = (body.p - point)

			distance_modulator = 1.0 - (vector.length / radius).clamp(0.0, 1.0)

			# apply force
			body.activate		# in case it was sleeping
			body.apply_impulse(vector.normalize * force * distance_modulator, CP::ZERO_VEC_2)

			# apply damage
			if damage_drawables(body.drawables, damage_amount, damage_type=:explosion)
				exit_drawables(body.drawables)
			end
		}
	end

	# Begins exiting of a drawable-- this is the only way to destroy something
	def exit_drawable(drawable)
		return if drawable.exiting?
		drawable.begin_exit!																	# Removal happens in render_prune_drawables

		# Map Feature: explosion-radius, explosion-force, explosion-damage
		options = drawable.level_object.options
		explosion_radius, explosion_force, explosion_damage = options[:explosion_radius], options[:explosion_force], options[:explosion_damage]
		if (explosion_force || explosion_damage)
			explosion_at(drawable.body.p, as_float(explosion_radius, 0.1), as_float(explosion_force, 1.0), as_float(explosion_damage, 0.0), exclude_body=drawable.body)
		end

		@bodies_to_remove << drawable.body if drawable.body		# TODO: options[:exit_still]
	end

	# (plurized helper)
	def exit_drawables(drawables)
		drawables.each { |drawable| exit_drawable(drawable) } if drawables		# the 'if' prevents attempts to destroy something not meant to be destroyed (eg. wall) by eg. destroy-on-touch object
	end

	def shutdown!
		@drawable_objects.each { |drawable| drawable.finalize! }
		@spawners_by_event.each_pair { |event, array| array.each { |spawner| spawner.shutdown! } }
		@trigger_collision_handlers.each { |handler| handler.shutdown! }
	end

	#
	# Stats and optional optimizations
	#
	def report_stats
		puts "- #{@drawable_objects.size} Drawables (#{@drawable_objects.map { |drawable| ((lo=drawable.level_object) && (lo.options[:spawner] == YES)) ? "[#{drawable.letter}]" : drawable.letter }.join })"

		spawner_count = 0 ; @spawners_by_event.each_pair { |event, spawners| spawner_count += spawners.count }
		breakable_constraint_count = 0 ; @breakable_constraints_by_event.each_pair { |event, breakables| breakable_constraint_count += breakables.count }
		has_physical_objects = ((spawner_count > 0) or (@drawable_objects.find { |d| ((d.is_a?(DrawableConstraint)) or (d.is_a?(DrawableObject) and (d.body or d.shapes)) or (d.is_a?(DrawableGroup))) } != nil))

		if has_physical_objects
			puts "- #{@updateables.size} Updateables"
			puts "- #{spawner_count} Spawners"
			puts "- #{breakable_constraint_count} Breakable Constraints by Event"
			puts "- #{@breakable_constraints.count} Breakable Constraints by force"
			puts "- #{@static_path_segments.size} Static Path Segments"
		else
			remove_space
			puts "- (no physics)"
		end

		puts "- default draw-method: #{@draw_method.to_s}" if @draw_method
		puts "- render-actor: #{@render_actor.title}" if @render_actor
		puts "- actor-effects: #{@actor_effects.title}" if @actor_effects
	end

	def render_drawable(drawable)
		drawable.render!
	end

	def optimize!
		return unless ENABLE_DRAWABLE_LIST_OPTIMIZATIONS

		draw_proc = method(:render_drawable)

		i = 0
		while @drawable_objects[i]
			# Skip non-suitable
			while ((drawable=@drawable_objects[i]) and not DrawableStaticList.suitable?(drawable))
				i += 1
			end
			# Gather suitable
			start_index = i
			while ((drawable=@drawable_objects[i]) and DrawableStaticList.suitable?(drawable))
				i += 1
			end
			# Got some?
			length = (i - start_index)
			if length > 1
				drawable = DrawableStaticList.new(self, @drawable_objects[start_index, length], draw_proc)
				@drawable_objects[start_index, length] = drawable

				# Skip back to the starting index, as they've all been collapsed into one
				i = start_index + 1
			end
		end
	end

	#
	# Class methods
	#
	def self.object_creates_a_constraint?(object)
		CONSTRAINT_KEYS.find { |key| !object.options[key].nil? } != nil
	end

	def self.conditional_events_pass?(options)
		# Map Feature: 'if-event'
		return false if (if_event_name=options[:if_event]) and (if_event=find_event_by_name(if_event_name)) and (if_event.now? == false)
		# Map Feature: 'unless-event'
		return false if (unless_event_name=options[:unless_event]) and (unless_event=find_event_by_name(unless_event_name)) and (unless_event.now? == true)
		return true
	end
end
