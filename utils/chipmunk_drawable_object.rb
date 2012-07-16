#
# Note that DrawableObject used to be a struct and retains much of the feel of one. The transition to full object status is ongoing.
#
require 'drawing'

class DrawableObject
	include Drawing

	attr_accessor :body, :shapes, :shape_offset, :level_object, :display_list, :angle, :scale_x, :scale_y, :render_actor, :child_index, :draw_proc, :fully_static, :entered_at, :enter_time, :exited_at, :exit_time, :activation, :activation_count, :activation_time, :sound_id, :scheduled_exit_at, :damage, :z
	boolean_accessor :takes_damage, :exit_still

	def initialize(simulator, body, shapes, shape_offset, level_object, angle, scale_x, scale_y, render_actor, child_index, draw_proc, fully_static)
		@simulator, @body, @shapes, @shape_offset, @level_object, @angle, @scale_x, @scale_y, @render_actor, @child_index, @draw_proc, @fully_static = simulator, body, shapes, shape_offset, level_object, angle, scale_x, scale_y, render_actor, child_index, draw_proc, fully_static
		@options = @level_object.options		# for easy access

		@exit_still = (@options[:exit_still] == YES)
		@on_exit = @options[:on_exit]
		$engine.new_button_notify_if_needed(@on_exit) if @on_exit

		@activation_variable = find_variable_by_name(@options[:activation_variable])
		@activation = 0.0
		@activation_count = 0
		@activation_time = as_float(@options[:activation_time], 1.0)

		@auto_roll = as_float(@options[:roll_rate], 0.0)

		@looping_sound_rotational_velocity_volume_min = as_float(@options[:looping_sound_rotational_velocity_volume_min], 1.0)
		@looping_sound_rotational_velocity_volume_max = as_float(@options[:looping_sound_rotational_velocity_volume_max], 1.0)
		@looping_sound_velocity_volume_min = as_float(@options[:looping_sound_velocity_volume_min], 1.0)
		@looping_sound_velocity_volume_max = as_float(@options[:looping_sound_velocity_volume_max], 1.0)

		@looping_sound_velocity_pitch_min = as_float(@options[:looping_sound_velocity_pitch_min], 1.0)
		@looping_sound_velocity_pitch_max = as_float(@options[:looping_sound_velocity_pitch_max], 1.0)
		@looping_sound_rotational_velocity_pitch_min = as_float(@options[:looping_sound_rotational_velocity_pitch_min], 1.0)
		@looping_sound_rotational_velocity_pitch_max = as_float(@options[:looping_sound_rotational_velocity_pitch_max], 1.0)

		@draw_method = as_draw_method(@options[:draw_method])

		@damage_slider = @options[:damage_slider]
		$engine.on_slider_change(@damage_slider, 0.0) if @damage_slider

		@z = as_float(@options[:z], 0.0)

		#@angle += as_float(@options[:angle], 0.0) if @angle	# this causes wrong angle results: reuse of :angle causing angle to be applied twice

		@takes_damage = (@options[:takes_damage] == YES)
		@damage = 0.0
		@damage_multiplier = as_float(@options[:damage_multiplier], 1.0)

		@display_list = nil
	end

	#
	# Helpers
	#
	def fully_static?
		((@fully_static == true) and !autoroll?)
	end

	def each_shape(&proc)
		@shapes.each(&proc) if @shapes
	end

	#
	# Autoroll (rolling of otherwise static rectangles)
	#
	def autoroll?
		@auto_roll != 0.0
	end

	def autoroll_angle
		(@auto_roll * $env[:time]) % 1.0
	end

	#
	# Activation (general concept of visual-only "activation", only used if render-actor/effects-actor)
	#
	def activate! 
		@activation_count += 1
	end

	def deactivate!
		@activation_count -= 1
	end

	def activation
		if @body
			# physical stuff is touch-activation + (variable or 0.0)
			@activation + (@activation_variable ? resolve_variable(@activation_variable) : 0.0)
		else
			# Static stuff is (variable or 1.0)
			(@activation_variable ? resolve_variable(@activation_variable) : 1.0)
		end
	end

	#
	# Damage
	#
	DAMAGE_MAX = 1.0
	DAMAGE_DEATH = 0.99		# allow for floating point error with eg. four hits of 0.25 ending up at 0.999999995

	def damage!(amount)		# returns whether "killed" or not
		return false unless @takes_damage
		@damage = (@damage + (amount * @damage_multiplier)).clamp(0.0, DAMAGE_MAX)
		$engine.on_slider_change(@damage_slider, @damage) if @damage_slider
		return (@damage >= DAMAGE_DEATH)
	end

	#
	#
	#
	def update!
		# Update activation
		if @activation_count.nil?
			# nothing
		elsif @activation_count > 0
			@activation = (@activation + (@activation_count * ($env[:time_delta] / @activation_time))).clamp(0.0, 1.0)
		else
			@activation = (@activation - (($env[:time_delta] / @activation_time))).clamp(0.0, 1.0)
		end

		update_looping_sound! if ($sound and @sound_id)
	end

	def update_looping_sound!
		# Position
		$sound.update_position(@sound_id, @body.p) if @body

		#
		# Map Features: 'looping-sound-velocity-volume-min/max', 'looping-sound-rotational-velocity-volume-min/max'
		#
		if (@body.w_limit != CP::INFINITY)
			volume = as_float(@options[:looping_sound_volume], 1.0)

			# Volume via velocity
			volume *= (@body.w.abs / @body.w_limit).scale(@looping_sound_velocity_volume_min, @looping_sound_velocity_volume_max)

			# Volume via rotational velocity
			volume *= (@body.w.abs / @body.w_limit).scale(@looping_sound_rotational_velocity_volume_min, @looping_sound_rotational_velocity_volume_max)

			$sound.update_volume(@sound_id, volume)
		end

		#
		# Map Features: 'looping-sound-velocity-pitch-min/max', 'looping-sound-rotational-velocity-pitch-min/max'
		#
		if (@body.v_limit != CP::INFINITY) or (@body.w_limit != CP::INFINITY)
			pitch = 1.0

			# Pitch via velocity
			pitch *= (body.v.length.abs / body.v_limit).scale(@looping_sound_velocity_pitch_min, @looping_sound_velocity_pitch_max) if (body.v_limit == CP::INFINITY)

			# Pitch via rotation speed
			pitch *= (@body.w.abs / @body.w_limit).scale(@looping_sound_rotational_velocity_pitch_min, @looping_sound_rotational_velocity_pitch_max) if (@body.w_limit != CP::INFINITY)

			$sound.update_pitch(@sound_id, pitch)
		end
	end

	def render!
		return unless @draw_proc
		if @draw_method
			with_pixel_combine_function(@draw_method) {
				@draw_proc.call(self)
			}
		else
			@draw_proc.call(self)
		end
	end

	#
	# Exiting (beginning of a graceful animated shutdown)
	#
	def begin_exit!
		# Mark start of death
		@exited_at = $env[:time]

		# Play exit sound
		$sound.play(@options[:exit_sound], :at => (@body ? @body.p : nil), :volume => as_float(@options[:exit_sound_volume], 1.0), :pitch => as_float(@options[:exit_sound_pitch], 1.0)) if $sound and @options[:exit_sound]

		# Exit button press
		$engine.on_button_press(@on_exit, 1) if @on_exit

		# End looping sound
		$sound.stop_by_id(@sound_id) if $sound and @sound_id
		@sound_id = nil
	end

	def exiting?
		!@exited_at.nil?		# Already on the way out?
	end

	#
	# Shutdown
	#
	def finalize!
		# OpenAL and OpenGL need some cleanup
		$sound.remove_by_id(@sound_id) if @sound_id
		GL.DestroyList(@display_list) if @display_list
		@sound_id, @display_list, @draw_proc = nil, nil, nil
	end

	#
	# Debugging
	#
	def letter
		if draw_proc.nil?
			' '
		else
			case fully_static
			when true
				'S'
			when :partial
				'p'
			else
				'.'
			end
		end
	end
end
