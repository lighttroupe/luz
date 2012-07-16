class TriggerCollisionHandler
	def initialize(simulator, object)
		@simulator, @object = simulator, object
		@overlap_body_count_hash = Hash.new { |hash, key| hash[key] = 0 }
		@overlap_shape_set = Set.new
		@while_event = find_event_by_name(@object.options[:while_event])
		@while_not_event = find_event_by_name(@object.options[:while_not_event])
	end

	def while_event_condition?
		(@while_event.nil? or @while_event.now?) and (@while_not_event.nil? or !@while_not_event.now?)
	end

	def begin(trigger_shape, other_shape, arbiter)
		# All done, if 'while-event' is off.  However, we do return true so we track this collision. 
		return true unless while_event_condition?

		# Register the contact
		add_overlap_body(other_shape.body, other_shape)
		true
	end

	def add_overlap_body(body, other_shape)
		# Ignore duplicates for the same shape
		return if @overlap_shape_set.include? other_shape
		@overlap_shape_set << other_shape

		@overlap_body_count_hash[body.object_id] += 1

#puts "+1 for #{other_shape}"
#puts "@overlap_body_count_hash[#{body.object_id}] == #{@overlap_body_count_hash[body.object_id]}"

		return if @overlap_body_count_hash[body.object_id] > 1

#		@overlap_body_set << body.object_id
		overlap_count = @overlap_body_count_hash.size

		if (follow_body=@object.options[:set_follow])
			@simulator.parent.add_follow_body(body) if follow_body == YES
			@simulator.parent.remove_follow_body(body) if follow_body == NO
		end

		# rare use of $env[]= outside of the engine, breaking rules is sexy
		if @object.options[:next_director] 
			$env[:next_director] = @object.options[:next_director]
			$env[:next_director_fade_time] = as_float(@object.options[:next_director_fade_time])
			$env[:next_director_fade_actor] = @object.options[:next_director_fade_actor]
		end

		# Map Feature: trigger 'on-overlap' button press (only when going 0->1 objects)
		#if overlap_count == 1 and (button = @object.options[:on_overlap])
		#	$engine.on_button_down(button)
		#end

		#if @object.options[:sound_environment]
		#	$sound.push_environment(@object.options[:sound_environment]) if $sound
		#end

		# Map Feature: trigger 'on-touch' button press
		button = @object.options[:on_touch]

#puts "trigger #{@object.options[:id]} sending #{button} for #{other_shape}"

		$engine.on_button_press(button, 1) if button

		# Map Feature: trigger 'on-touch-TYPE' button press
		button = @object.options[$collision_type_symbol_to_on_touch_key[other_shape.collision_type]]
		$engine.on_button_press(button, 1) if button

		# Map Feature: trigger 'on-overlap' button press (only when going 0->1 objects)
		if overlap_count == 1 and (button = @object.options[:on_overlap])
			$engine.on_button_down(button)
		end

		# Map Feature: trigger 'on-overlap-sound' (only when going 0->1 objects)
		if overlap_count == 1 and (sound_path = @object.options[:on_overlap_sound])
			# TODO: play :at => the point of contact
			@overlap_sound_id = $sound.play(sound_path, :at => other_shape.body.p, :looping => true, :volume => as_float(@object.options[:on_overlap_sound_volume], 1.0), :pitch => as_float(@object.options[:on_overlap_sound_pitch], 1.0))
		end

		# Map Feature: trigger 'activates: yes'
		if @object.options[:activates] == YES
			other_shape.body.drawables.each { |drawable| drawable.activate! }
		end

		#if (button = @object.options["on-overlap-#{overlap_count}"])
		#end

		#if $sound and (sound = @object.options["on-overlap-#{overlap_count}-sound"])
		#$sound.play(object.options[:looping_sound], :at => body.p, :volume => as_float(object.options[:looping_sound_volume], 1.0), :pitch => as_float(object.options[:looping_sound_pitch], 1.0), :looping => true) if ($sound and object.options[:looping_sound])

		# Map Feature: overlap impulse (a constant applied when entering, removed when leaving)
		overlap_impulse_x = @object.options[:overlap_impulse_x]
		overlap_impulse_y = @object.options[:overlap_impulse_y]
		if (overlap_impulse_x or overlap_impulse_y)
			overlap_impulse = CP::Vec2.new(as_float(overlap_impulse_x), as_float(overlap_impulse_y))
			other_shape.body.activate						# in case it was sleeping
			other_shape.body.apply_force(overlap_impulse, CP::ZERO_VEC_2)
		end

		# Map Feature: touch impulse (an impulse applied on first touch)
		touch_impulse_x = @object.options[:touch_impulse_x]
		touch_impulse_y = @object.options[:touch_impulse_y]
		if (touch_impulse_x or touch_impulse_y)
			touch_impulse = CP::Vec2.new(as_float(touch_impulse_x), as_float(touch_impulse_y))
			other_shape.body.activate						# in case it was sleeping
			other_shape.body.apply_impulse(touch_impulse, CP::ZERO_VEC_2)
		end

		# Map Feature: touch impulse forward (an impulse applied on first touch)
		if (touch_impulse_forward = @object.options[:touch_impulse_forward])
			touch_impulse = other_shape.body.v.normalize_safe * as_float(touch_impulse_forward, 0.0)
			other_shape.body.activate						# in case it was sleeping
			other_shape.body.apply_impulse(touch_impulse, CP::ZERO_VEC_2)
		end

		# Map Feature: destroy-on-touch and destroy-on-touch-TYPE
		if (@object.options[:destroy_on_touch] == YES) or (@object.options[$collision_type_symbol_to_destroy_on_touch_key[other_shape.collision_type]] == YES)
			@simulator.exit_drawables(other_shape.body.drawables)
		end

		# Now, on to sound...
		return unless $sound

		# Map Feature: 'on-touch-sound'
		sound_path = @object.options[:on_touch_sound]
		return unless sound_path

		volume = as_float(@object.options[:on_touch_sound_volume], 1.0)
		pitch = as_float(@object.options[:on_touch_sound_pitch], 1.0)
		$sound.play(sound_path, :at => other_shape.body.p, :volume => volume, :pitch => pitch)
	end

	def separate(trigger_shape, other_shape, arbiter)
		remove_overlap_body(other_shape.body, other_shape)
	end

	def remove_overlap_body(body, other_shape)
		# Ignore call unless we were overlapping shape and delete shape from set
		return unless @overlap_shape_set.delete?(other_shape)

		# Decrement the number of shape collisions for this body
		@overlap_body_count_hash[body.object_id] -= 1
		#puts "@overlap_body_count_hash[#{body.object_id}] == #{@overlap_body_count_hash[body.object_id]}"

		# If there are other shapes of the same body overlapping, we're done for now
		return if @overlap_body_count_hash[body.object_id] > 0

		# Remove body all together, so our overlap counts are accurate
		@overlap_body_count_hash.delete(body.object_id)
		overlap_count = @overlap_body_count_hash.size
		#puts "overlap_count = #{overlap_count}"

		# Map Feature: 'overlap-impulse-x', 'overlap-impulse-y'
		overlap_impulse_x = @object.options[:overlap_impulse_x]
		overlap_impulse_y = @object.options[:overlap_impulse_y]
		if (overlap_impulse_x or overlap_impulse_y)
			overlap_impulse = CP::Vec2.new(as_float(overlap_impulse_x), as_float(overlap_impulse_y))
			other_shape.body.apply_force(-overlap_impulse, CP::ZERO_VEC_2)
		end

		# Map Feature: 'activates: yes' here we turn it off by 1
		if @object.options[:activates] == YES
			other_shape.body.drawables.each { |drawable| drawable.deactivate! }
		end

		# Map Feature: 'on-overlap' button press (only when going 1->0 objects)
		if overlap_count == 0 
			if (button=@object.options[:on_overlap])
				$engine.on_button_up(button)
			end
			stop_overlap_sound
		end
	end

	def shutdown!
		overlap_count = @overlap_body_count_hash.size
		if overlap_count > 0 and (button = @object.options[:on_overlap])
			$engine.on_button_up(button)
		end
		stop_overlap_sound
	end

	def stop_overlap_sound
		$sound.stop_by_id(@overlap_sound_id) if @overlap_sound_id
		@overlap_sound_id = nil
	end
end

class TriggerCollisionOverlapHandler < TriggerCollisionHandler
	OPTIONS_REQUIRING_PRE_SOLVE = [:while_event, :slider_across_x, :slider_across_y, :slider_radial, :velocity_multiply, :velocity_multiply_x, :velocity_multiply_y, :set_velocity_x, :set_velocity_y]

	def self.object_requires_overlap_handler?(object)
		!(object.options.keys & OPTIONS_REQUIRING_PRE_SOLVE).empty?
	end

	def initialize(simulator, object)
		super(simulator, object)
		@last_object_pre_solve_frame_number = {}

		@velocity_multiply, @velocity_multiply_x, @velocity_multiply_y = as_float(@object.options[:velocity_multiply], 1.0), as_float(@object.options[:velocity_multiply_x], 1.0), as_float(@object.options[:velocity_multiply_y], 1.0)

		@slider_across_x, @slider_across_x_min, @slider_across_x_max = @object.options[:slider_across_x], as_float(@object.options[:slider_across_x_min], 0.0), as_float(@object.options[:slider_across_x_max], 1.0)
		$engine.on_slider_change(@slider_across_x, 0.0) if @slider_across_x
		@slider_across_y, @slider_across_y_min, @slider_across_y_max = @object.options[:slider_across_y], as_float(@object.options[:slider_across_y_min], 0.0), as_float(@object.options[:slider_across_y_max], 1.0)
		$engine.on_slider_change(@slider_across_y, 0.0) if @slider_across_y
		@slider_radial, @slider_radial_min, @slider_radial_max = @object.options[:slider_radial], as_float(@object.options[:slider_radial_min], 0.0), as_float(@object.options[:slider_radial_max], 1.0)
		$engine.on_slider_change(@slider_radial, 0.0) if @slider_radial

		#
		# NOTE: new options should be added to OPTIONS_REQUIRING_PRE_SOLVE
		#
	end

	#
	# In pre_solve we handle the features that need to run ruby code each frame
	#
	def pre_solve(trigger_shape, other_shape, arbiter)
		#
		# NOTE: new options should be added to OPTIONS_REQUIRING_PRE_SOLVE
		#
		if @while_event
			# these are duplicate-call tolerant
			if @while_event.now?
				add_overlap_body(other_shape.body, other_shape)
			else
				remove_overlap_body(other_shape.body, other_shape)
				return true
			end
		end

		# Early-out if this isn't the first contact on this frame
		frame_number, key = $env[:frame_number], other_shape.object_id
		return true if @last_object_pre_solve_frame_number[key] == frame_number
		@last_object_pre_solve_frame_number[key] = frame_number

		# Map Feature: 'set-velocity-x', 'set-velocity-y' of overlapping objects
		set_velocity_x, set_velocity_y = @object.options[:set_velocity_x], @object.options[:set_velocity_y]
		other_shape.body.v.x = as_float(set_velocity_x) if set_velocity_x
		other_shape.body.v.y = as_float(set_velocity_y) if set_velocity_y

		# Map Feature: 'slider-across-x'
		if @slider_across_x
			bb = trigger_shape.bb
			progress = ((other_shape.body.p.x - bb.l) / (bb.r - bb.l)).clamp(0.0, 1.0)
			value = progress.scale(@slider_across_x_min, @slider_across_x_max)
			$engine.on_slider_change(@slider_across_x, value)
		end

		# Map Feature: 'slider-across-y'
		if @slider_across_y
			bb = trigger_shape.bb
			progress = ((other_shape.body.p.y - bb.b) / (bb.t - bb.b)).clamp(0.0, 1.0)
			value = progress.scale(@slider_across_y_min, @slider_across_y_max)
			$engine.on_slider_change(@slider_across_y, value)
		end

		# Map Feature: 'slider-radial'
		if @slider_radial
			position = (other_shape.body.p - trigger_shape.body.p)		# in trigger coordinates, worldspace units
			bb = trigger_shape.bb
			radius = ((bb.t - bb.b) + (bb.r - bb.l)) / 4.0		# 2 (for (a+b)/2) * 2 (for diameter-to-radius)
			progress = position.length / radius
			value = progress.scale(@slider_radial_min, @slider_radial_max)
			$engine.on_slider_change(@slider_radial, value)
		end

		# Map Feature: 'velocity-multiply'
		other_shape.body.v.x *= (@velocity_multiply * @velocity_multiply_x)
		other_shape.body.v.y *= (@velocity_multiply * @velocity_multiply_y)

		#
		# NOTE: new options should be added to OPTIONS_REQUIRING_PRE_SOLVE
		#
		return true
	end

	def separate(trigger_shape, other_shape, arbiter)
		super

		# Ensure that the min/max value is sent when an objects exits (otherwise it might jump from 0.95 to outside in one update)
		return unless (@slider_across_x or @slider_across_y)
		trigger_bb = trigger_shape.bb
		other_bb = other_shape.bb
		if @slider_across_x
			$engine.on_slider_change(@slider_across_x, @slider_across_x_min) if other_bb.r < trigger_bb.l
			$engine.on_slider_change(@slider_across_x, @slider_across_x_max) if other_bb.l > trigger_bb.r
		end

		if @slider_across_y
			$engine.on_slider_change(@slider_across_y, @slider_across_y_min) if other_bb.t < trigger_bb.b
			$engine.on_slider_change(@slider_across_y, @slider_across_y_max) if other_bb.b > trigger_bb.t
		end
	end

	def shutdown!
		#$engine.on_slider_change(@slider_across_x, 0.0) if @slider_across_x
		#$engine.on_slider_change(@slider_across_y, 0.0) if @slider_across_y
		super
	end
end
