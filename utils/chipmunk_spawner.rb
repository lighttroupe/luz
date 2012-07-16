class Spawner
	attr_reader :object
	def initialize(simulator, object)
		@simulator, @object, @body, @offset_from_body, @drawable_objects = simulator, object, nil, CP::ZERO_VEC_2, []

		# Map Feature: 'spawn-every'
		@spawn_attempts = 0
		@spawn_every = as_integer(@object.options[:spawn_every], 1)
		@spawn_every_offset = as_integer(@object.options[:spawn_every_offset], 0)

		@while_event = find_event_by_name(@object.options[:while_event])
		@while_not_event = find_event_by_name(@object.options[:while_not_event])

		@next_child_index = 0
	end

	def set_body_relative(body)
		@body = body
		@offset_from_body = (CP::Vec2.new(@object.x,  @object.y) - @body.p)
	end

	def while_event_condition?
		(@while_event.nil? or @while_event.now?) and (@while_not_event.nil? or !@while_not_event.now?)
	end

	def spawn!
		return unless while_event_condition?

		# Map Feature: 'spawn-every' for patterns (1, 5, 9, 13, etc.)
		@spawn_attempts += 1
		unless (((@spawn_attempts + @spawn_every_offset) % @spawn_every) == 0)
			sound = @object.options[:spawn_every_sound]
			$sound.play(sound, :volume => as_float(@object.options[:spawn_every_sound_volume], 1.0), :pitch => as_float(@object.options[:spawn_every_sound_pitch], 1.0)) if $sound and sound
			return
		end

		limit = as_integer(@object.options[:spawner_limit], 50)

		alive_count = @drawable_objects.count { |d| !d.exiting? }
		if (alive_count >= limit)
			if @object.options[:spawner_limit_destroy] == YES
				@simulator.exit_drawable(@drawable_objects.find { |d| !d.exiting? })
			else
				# Map Feature: spawner-limit-sound played when spawning failed
				sound = @object.options[:spawner_limit_sound]
				$sound.play(sound, :volume => as_float(@object.options[:spawner_limit_sound_volume], 1.0), :pitch => as_float(@object.options[:spawner_limit_sound_pitch], 1.0)) if $sound and sound
				return
			end
		end

		# Otherwise go ahead and make one...
		spawn
	end

	def render!
		return if @drawable_objects.empty?
		@simulator.render_prune_drawables(@drawable_objects)
	end

	def shutdown!
		@drawable_objects.each { |drawable| drawable.finalize! }
	end

private

	def spawn
		@simulator.create_object(@object, body=nil, from_spawner=true) { |drawable|
			# Map Feature: body-relative spawner
			if (@body and drawable.body)
				if @object.options[:rotate_with_body] == YES			# TODO: if body-relative-rotation == YES
					# Apply stored position offset (rotated)
					drawable.body.p = (@body.p + @offset_from_body.rotate(@body.rot))

					# Rotate spawned body
					drawable.body.a += @body.a

					# Rotate starting velocity
					unless (velocity=drawable.body.v).length == 0.0
						#drawable.body.v = (drawable.body.v.normalize.rotate(@body.rot)) * drawable.body.v.length
						drawable.body.v = (drawable.body.v.rotate(@body.rot))
					end

					# Rotate starting force
					unless (force=drawable.body.f).length == 0.0
						#drawable.body.f = (force.normalize.rotate(@body.rot)) * force.length
						drawable.body.f = (force.rotate(@body.rot))
					end
				else
					# Apply stored position offset (not rotated)
					drawable.body.p = (@body.p + @offset_from_body)
				end

				# Spawned object gets body's velocity, otherwise object will likely immediately bump into spawned objects, etc.
				drawable.body.v += @body.v unless @object.options[:velocity_from_body] == NO
			end

			# Set spawner-specific drawable fields
			drawable.child_index = @next_child_index ; @next_child_index += 1
			drawable.entered_at = $env[:time]
			drawable.enter_time = as_float(@object.options[:enter_time])
			drawable.exit_time = as_float(@object.options[:exit_time])
			drawable.exited_at = nil

			# Map Feature: 'lifetime' (in seconds)
			drawable.scheduled_exit_at = ($env[:time] + drawable.enter_time + as_float(@object.options[:lifetime], 1.0)) if @object.options[:lifetime]

			# Map Feature: 'on-spawn-sound'
			if (sound_path=@object.options[:on_spawn_sound])
				$sound.play(sound_path, :at => drawable.body.p, :volume => as_float(@object.options[:on_spawn_sound_volume], 1.0), :pitch => as_float(@object.options[:on_spawn_sound_pitch], 1.0)) if $sound and drawable.body
			end

			# Map Feature: 'spawn-below'
			if @object.options[:spawn_below] == YES
				@drawable_objects.unshift(drawable)
			else
				@drawable_objects << drawable
			end
		}
	end
end
