class PhysicalObjectCollisionHandler
	DYNAMIC_OPTION_PATTERNS = [/on_touch_.*/, /destroy_on_touch_.*/, /die_on_touch_.*/, /damage_on_touch_.*/]

	PHYSICAL_OBJECT_OPTIONS_REQUIRING_PRE_SOLVE_HANDLER = Set.new([:pass_left, :pass_right])
	PHYSICAL_OBJECT_OPTIONS_REQUIRING_HANDLER = Set.new([:on_touch, :on_touch_sound, :die_on_touch, :destroy_on_touch, :maximum_collision_intensity]) + PHYSICAL_OBJECT_OPTIONS_REQUIRING_PRE_SOLVE_HANDLER

	def initialize(simulator)
		@simulator = simulator
		@last_object_pair_post_solve_frame_number = Hash.new { |hash, key| hash[key] = {} }		# TODO: prune this somehow
	end

	#hit_velocity = calculate_hit_velocity(shape_a.body, shape_b.body, arbiter.point(0), arbiter.normal(0)).abs
	#def calculate_hit_velocity(body_a, body_b, point, normal)
	#	r1 = point - body_a.p
	#	r2 = point - body_b.p
	#	v1_sum = body_a.v + (r1.perp * body_a.w)
	#	v2_sum = body_b.v + (r2.perp * body_b.w)
	#	return (v2_sum - v1_sum).dot(normal)
	#end

	# TODO: put these elsewhere?  as methods?  =>  used by trigger as well
	$collision_type_symbol_to_on_touch_key ||= Hash.new { |hash, key| hash[key] = "on_touch_#{key.to_s}".to_sym } 
	$collision_type_symbol_to_die_on_touch_key ||= Hash.new { |hash, key| hash[key] = "die_on_touch_#{key.to_s}".to_sym } 
	$collision_type_symbol_to_destroy_on_touch_key ||= Hash.new { |hash, key| hash[key] = "destroy_on_touch_#{key.to_s}".to_sym } 
	$collision_type_symbol_to_damage_on_touch_key ||= Hash.new { |hash, key| hash[key] = "damage_on_touch_#{key.to_s}".to_sym } 

	def post_solve(shape_a, shape_b, arbiter)		# (Chipmunk collisions callback, discovered automatically)
		#puts "#{shape_a.level_object.options[:id]} vs #{shape_b}"

		# Early-out if this isn't the first contact in this step (already handled)
		return true unless arbiter.first_contact?

		# It's tempting to filter out super low intensity touches here.
		# This way was found to be troublesome.  TODO: Try again with a way smaller constant?  How to ensure "reasonable" collisions do generate a response?
		# 	collision_distance = arbiter.impulse(true).length
		# 	return true unless collision_distance > MINIMUM_COLLISION_DISTANCE_FOR_TOUCH_RESPONSE

		# Early-out if this isn't the first contact on this frame
		# TODO: do we need to filter by body also, to avoid multiple on_touch responses?
		frame_number, key_1, key_2 = $env[:frame_number], shape_a.object_id, shape_b.object_id
		return true if @last_object_pair_post_solve_frame_number[key_1][key_2] == frame_number		# TODO: this gets poluted over time, though it's per-level, ensure this gets purged!
		@last_object_pair_post_solve_frame_number[key_1][key_2] = frame_number

		# Cache each object's options
		options_a = shape_a.level_object.options
		options_b = shape_b.level_object.options

		collision = true		# assume yes

		# How far did shapes collide?
		arbiter_impulse_length = arbiter.impulse.length.abs
		collision_intensity = (arbiter_impulse_length * 2).clamp(0.0, 1.0)
		#puts sprintf("impulse: %0.05f, sound: %0.05f, collision: %0.05f", arbiter_impulse_length, sound_impact_intensity, collision_intensity)

		#
		# Map Feature: 'on-touch', 'destroy-on-touch', 'die-on-touch', and 'maximum-collision-intensity'
		#
		object_a_killed = false
		on_touch_a = options_a[:on_touch]		# name of a fake button press to send to Luz
		on_touch_collision_type_a = options_a[$collision_type_symbol_to_on_touch_key[shape_b.collision_type]]
		$engine.on_button_press(on_touch_a, 1) if on_touch_a
		$engine.on_button_press(on_touch_collision_type_a, 1) if on_touch_collision_type_a

		# Does B destroy, or specifically destroy us?
		if (options_b[:destroy_on_touch] == YES) or (options_b[$collision_type_symbol_to_destroy_on_touch_key[shape_a.collision_type]] == YES)
			@simulator.exit_drawables(shape_a.body.drawables)
			collision = false
			object_a_killed = true

		# Does A die, or specifically die when touching B?
		elsif (options_a[:die_on_touch] == YES) or (options_a[$collision_type_symbol_to_die_on_touch_key[shape_b.collision_type]] == YES)
			@simulator.exit_drawables(shape_a.body.drawables)
			object_a_killed = true

		# Was A crushed?
		elsif (options_a[:maximum_collision_intensity] and (collision_intensity > as_float(options_a[:maximum_collision_intensity])))
			# smashed
			@simulator.exit_drawables(shape_a.body.drawables)
			object_a_killed = true

		elsif ((damage_amount=options_b[:damage_on_touch]) or (damage_amount=options_b[$collision_type_symbol_to_damage_on_touch_key[shape_a.collision_type]]))
			damage_amount = as_float(damage_amount) * as_float(options_a[:damage_multiplier], 1.0)
			if damage_drawables(shape_a.body.drawables, damage_amount)
				@simulator.exit_drawables(shape_a.body.drawables)
				object_a_killed = true
			end
		end

		# Handle B
		object_b_killed = false
		on_touch_b = options_b[:on_touch]		# name of a fake button press to send to Luz
		on_touch_collision_type_b = options_b[$collision_type_symbol_to_on_touch_key[shape_a.collision_type]]

		$engine.on_button_press(on_touch_b, 1) if (on_touch_b and (on_touch_b != on_touch_a))
		$engine.on_button_press(on_touch_collision_type_b, 1) if on_touch_collision_type_b

		# Does A destroy, or specifically destroy us?
		if (options_a[:destroy_on_touch] == YES) or (options_a[$collision_type_symbol_to_destroy_on_touch_key[shape_b.collision_type]] == YES)
			@simulator.exit_drawables(shape_b.body.drawables)
			collision = false
			object_b_killed = true

		# Does B die, or specifically die when touching A?
		elsif (options_b[:die_on_touch] == YES) or (options_b[$collision_type_symbol_to_die_on_touch_key[shape_a.collision_type]] == YES)
			@simulator.exit_drawables(shape_b.body.drawables)
			object_b_killed = true

		# Was B crushed?
		elsif (options_b[:maximum_collision_intensity] and (collision_intensity > as_float(options_b[:maximum_collision_intensity])))
			@simulator.exit_drawables(shape_b.body.drawables)
			object_b_killed = true

		elsif ((damage_amount=options_a[:damage_on_touch]) or (damage_amount=options_a[$collision_type_symbol_to_damage_on_touch_key[shape_b.collision_type]]))
			damage_amount = as_float(damage_amount) * as_float(options_b[:damage_multiplier], 1.0)
			if damage_drawables(shape_b.body.drawables, damage_amount)
				@simulator.exit_drawables(shape_b.body.drawables)
				object_b_killed = true
			end
		end

		# Now, on to sound...
		return collision unless $sound

		sound_impact_intensity = collision_intensity

		if sound_impact_intensity > 0.0
			# Map Feature: 'on-touch-sound'
			sound_path_a = options_a[:on_touch_sound]
			sound_path_b = options_b[:on_touch_sound]

			return collision unless sound_path_a or sound_path_b

			if (sound_path_a and (object_a_killed == false))		# don't play both sounds for A
				volume_a = as_float(options_a[:on_touch_sound_volume], 1.0) * sound_impact_intensity
				pitch_a = as_float(options_a[:on_touch_sound_pitch], 1.0)
				$sound.play(sound_path_a, :at => shape_a.body.p, :volume => volume_a, :pitch => pitch_a)
			end

			if (sound_path_b and (sound_path_b != sound_path_a) and object_b_killed == false)
				volume_b = as_float(options_b[:on_touch_sound_volume], 1.0) * sound_impact_intensity
				pitch_b = as_float(options_b[:on_touch_sound_pitch], 1.0)
				$sound.play(sound_path_b, :at => shape_b.body.p, :volume => volume_b, :pitch => pitch_b)
			end
		end

		return collision
	end

	def self.matches_dynamic_property_name?(name)
		DYNAMIC_OPTION_PATTERNS.find { |regex| (regex =~ name) == 0 }
	end

	def self.object_needs_handler?(object)
		object.options.keys.each { |key|
			return true if (PHYSICAL_OBJECT_OPTIONS_REQUIRING_HANDLER.include?(key) or matches_dynamic_property_name?(key.to_s))
		}
		return false
	end

	def self.object_needs_pre_solve_handler?(object)
		object.options.keys.each { |key| return true if (PHYSICAL_OBJECT_OPTIONS_REQUIRING_PRE_SOLVE_HANDLER.include?(key)) }
		return false
	end
end

class PhysicalObjectCollisionHandlerWithPreSolve < PhysicalObjectCollisionHandler
	def pre_solve(shape_a, shape_b, arbiter)
		# Currently we can assume that shape_a is a segment (see use of PhysicalObjectCollisionHandlerWithPreSolve)
		cross = arbiter.normal(0).cross(shape_a.b - shape_a.a)
		if cross > 0.0
			return false if shape_a.level_object.options[:pass_right] == YES
		elsif cross < 0.0
			return false if shape_a.level_object.options[:pass_left] == YES
		end
		return true
	end
end
