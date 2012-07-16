###############################################################################
#  Copyright 2011 Ian McIntosh <ian@openanswers.org>
###############################################################################

class DirectorEffectGamePhysicsPuzzle < DirectorEffect
	title 'Game Physics Puzzle'
	description 'Chipmunk 2D physics, Inkscape SVG level loading, OpenAL 3D Audio.'

	setting 'level_file_path', :string, :file_edit => true, :summary => true

	setting 'camera_mode', :select, :default => :follow_last, :options => [[:follow_last, 'Follow Latest'], [:follow_first, 'Follow Earliest'], [:follow_all, 'Follow All']]
	setting 'camera_x', :float, :default => 0.0..0.5
	setting 'camera_y', :float, :default => 0.0..0.5
	setting 'camera_z', :float, :default => 0.0..0.5
	setting 'camera_speed', :float, :default => 1.0..1.0, :range => 0.01..1000.0
	setting 'camera_damper', :float, :default => 1.0..1.0, :range => 0.001..1.0

	setting 'gravity_x', :float, :default => 0.0..0.5
	setting 'gravity_y', :float, :default => -0.1..0.0
	setting 'damping', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'speed_of_time', :float, :range => -2.0..2.0, :default => 1.0..2.0

	setting 'object_speed_variable', :variable
	setting 'object_rotation_variable', :variable
	setting 'object_rotation_speed_variable', :variable
	setting 'object_activation_variable', :variable
	setting 'object_sleeping_event', :event
	setting 'object_damage_variable', :variable

	setting 'reload', :event
	setting 'debug_mode', :event
	setting 'audible_distance', :float, :range => 0.001..10.0, :default => 0.01..10.0, :simple => true

	def deep_clone(*args)
		@level, @layers = nil, nil		# can't clone these
		super(*args)
	end

	def after_load
		require 'chipmunk_physics_simulator'
		require 'svg_level_loader'
		require 'chipmunk_property_deprecations'

		# after_load is called once when object is first created, and also after an engine reload
		do_reload
		super		# it must call 'super' for the object to be properly instantiated
	end

	attr_reader :follow_bodies, :last_camera_x, :last_camera_y

	def do_reload
		#puts "Reloading #{title}"
		shutdown!
		@level = nil if $gui		# TODO: only if changed on disk
		@layers = nil						# cause lazy-reload below
		@follow_bodies = []
		@objects_by_title = {}
		@objects_by_layer = Hash.new { |hash, key| hash[key] = [] }
		@last_camera_x, @last_camera_y, @last_camera_z = 0.0, 0.0, 0.0
	end

	def add_follow_body(body)
		@follow_bodies << body unless @follow_bodies.include? body
	end

	def remove_follow_body(body)
		@follow_bodies.delete(body)
	end

	def shutdown!
		@layers.each { |layer| layer.shutdown! } if @layers
	end

	def load_level(path)
		#
		# Load from SVG
		#
		@level = SVGLevelLoader.new
		@level.load(File.join($engine.project.file_path, path), $engine.project.file_path)
		return @level
	end

	def object_by_title(title)
		@objects_by_title[title]
	end

	def with_layer_positioning
		# Start with settings
		desired_x, desired_y, desired_z = camera_x, camera_y, camera_z

		if @follow_bodies.empty?
			# use only settings

		elsif ((camera_mode == :follow_last) && (follow_body = @follow_bodies.last)) or ((camera_mode == :follow_first) && (follow_body = @follow_bodies.first))
			desired_x += follow_body.p.x
			desired_y += follow_body.p.y

		elsif camera_mode == :follow_all
			min_x, max_x, min_y, max_y = 1.0/0.0, -1.0/0.0, 1.0/0.0, -1.0/0.0
			@follow_bodies.each { |b|
				min_x = b.p.x if b.p.x < min_x
				max_x = b.p.x if b.p.x > max_x
				min_y = b.p.y if b.p.y < min_y
				max_y = b.p.y if b.p.y > max_y
			}
			distance_x, distance_y = (max_x - min_x), (max_y - min_y)

			desired_x += (max_x + min_x) / 2.0
			desired_y += (max_y + min_y) / 2.0
			desired_z += (distance_x > distance_y) ? (distance_x / 3.0) : (distance_y / 2.0)		# these numbers are hacks, sort of assume ~90deg field of view (fov)

		else
			raise "unhandled camera_mode: #{camera_mode}"
		end

		# Damper
		damper_amount = 1.0
		distance_squared = ((desired_x - @last_camera_x)**2 + (desired_y - @last_camera_y)**2)
		if(distance_squared > 0.0)
			distance = distance_squared.square_root
			damper_amount = (camera_speed / distance).clamp(0.0, camera_damper)		# TODO: constant?
			@last_camera_x += ((desired_x - @last_camera_x) * damper_amount)
			@last_camera_y += ((desired_y - @last_camera_y) * damper_amount)
		end

		@last_camera_z += ((desired_z - @last_camera_z) * damper_amount)

		with_translation(-@last_camera_x, -@last_camera_y, -@last_camera_z) {
			yield
		}
	end

	def resolve_copy_from(object, depth=0)
		raise 'copy-from too deep' if depth > 4
		if (copy_from=object.options[:copy_from])
			if (other_object=object_by_title(copy_from))
				resolve_copy_from(other_object, depth+1)		# ensure the object has its copy-from respected, in case of chained copy-froms where the middle one is later in the array of objects
				object.options = other_object.options.merge(object.options)		# NOTE: local options take priority
			else
				puts "error: object #{object.options[:id]} copy-for references unknown title '#{copy_from}'" 
			end
			object.options.delete(:copy_from)
		end

		# Feature: copy-from on one object within a group should work
		if object.is_a? SVGLevelLoader::GroupObject
			object.objects.each { |child_object| resolve_copy_from(child_object, depth) }		# same depth
		end
	end

	def store_object_title_recursive(object)
		# Store relevant titles for easy referencing
		@objects_by_title[object.options[:title]] = object unless (object.options[:title].nil? or object.options[:title] == '')
		if object.is_a? SVGLevelLoader::GroupObject
			object.objects.each { |child_object| store_object_title_recursive(child_object) }
		end
	end

	# yields all objects of group
	def each_in_group(object, &proc)
		if object.is_a?(SVGLevelLoader::GroupObject)
			object.objects.each { |child_object| each_in_group(child_object, &proc) }
			proc.call(object)
		else
			proc.call(object)
		end
	end

	def create_layers
		@layers = []

		#puts "=== Create Layers ==="
		@level.each_layer { |layer| @layers << ChipmunkPhysicsSimulator.new(self, layer.name, layer.options) }

		# Iterative over all objects, storing them and saving named ones
		@level.each_element { |layer_index, object|
			store_object_title_recursive(object)
			@objects_by_layer[layer_index] << object
		}

		# Map Feature: Merge options for 'copy-from' (located by SVG 'title')
		@objects_by_layer.each_pair { |layer_index, objects|
			objects.each { |object| resolve_copy_from(object) }
		}

		# Map feature: remove objects if conditionals ('if-event', 'unless-event') fail
		# NOTE: we can still 'copy-from' objects that don't pass conditionals
		@objects_by_layer.each_pair { |layer_index, objects|
			objects.delete_if { |object| !ChipmunkPhysicsSimulator.conditional_events_pass?(object.options) }

			objects.each { |object| apply_deprecations(object) }
		}

		#puts "=== Create Drawable (non-Constraints) Objects (including drawn triggers) ==="
		@objects_by_layer.each_pair { |layer_index, objects| objects.each { |object| @layers[layer_index].create_object!(object) unless ChipmunkPhysicsSimulator.object_creates_a_constraint?(object) } }

		#puts "=== Create Constraints ==="
		@objects_by_layer.each_pair { |layer_index, objects| objects.each { |object| @layers[layer_index].create_object!(object) if ChipmunkPhysicsSimulator.object_creates_a_constraint?(object) }}

		#puts "=== Create Triggers ==="
		@objects_by_layer.each_pair { |layer_index, objects| objects.each { |object| each_in_group(object) { |child_object| @layers[layer_index].add_trigger(child_object) if child_object.options[:trigger] == YES }}}

		#puts "=== Creating Collision Callbacks ==="
		@layers.each_with_index { |layer, index| layer.create_collision_callbacks }

		puts "- #{@objects_by_title.count} named objects (#{@objects_by_title.keys.join(', ')})"
		@layers.each_with_index { |layer, index|
			puts "=== Layer '#{layer.name}' ==="
			layer.optimize!			# <=== don't comment this out :D
			layer.report_stats
		}

		# Some reminders
		unless ENABLE_DRAWABLE_LIST_OPTIMIZATIONS
			puts "****************************************"
			puts "** Drawable list optimizations is OFF **"
			puts "****************************************"
		end
		if $settings['no-shaders']
			puts "*****************************"
			puts "** GL Shaders are DISABLED **"
			puts "*****************************"
		end
	end

	#
	# tick is called once per frame, before rendering
	#
	def tick
		return shutdown! if ($env[:game_level_shutdown])

		# Level is live-reloadable
		do_reload if ((reload.on_this_frame?) or $env[:game_level_reset]) # or @previous_tick_frame_number != $env[:frame_number]-1)

		# Lazy-loading of level and layers
		load_level(level_file_path) unless @level
		create_layers unless @layers

		if $sound
			$sound.listener_position = [@last_camera_x, @last_camera_y, @last_camera_z]
			$sound.global_pitch = speed_of_time
			$sound.audible_distance = audible_distance
		end

		# Gravity and Damping are live-updateable from plugin settings
		@layers.each { |layer| layer.tick(speed_of_time, gravity_x, gravity_y, damping) }

		@previous_tick_frame_number = $env[:frame_number]
	end

	def render
		debug = debug_mode.now?
		@layers.each { |layer| layer.render!(debug) } if @layers
		yield		# must yield to continue down the Director Effects list
	end
end
