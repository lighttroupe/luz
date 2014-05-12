module MethodsForUserObject
	def first_frame?
		$env[:frame_number] == 1
	end

	def with_time_shift(second_offset, &proc)
		with_env(:time, ($env[:time] + second_offset), &proc)		 # TODO: how about a generic with_env_addition(:time, second_offset) { ... }
	end

	def with_beat_shift(beat_offset)
		old_beat, old_beat_number = $env[:beat], $env[:beat_number]
		$env[:beat] += beat_offset
		$env[:beat_number] += beat_offset
		yield
		$env[:beat], $env[:beat_number] = old_beat, old_beat_number
	end

	def with_env(var, value)
		old_value = $env[var]
		return yield if (value == old_value)
		$env[var] = value			# TODO: make cumulative += version
		yield
		$env[var] = old_value
	end

	def with_enter_and_exit(enter, exit)
		old_enter, old_exit = $env[:enter], $env[:exit]
		return yield if (enter == old_enter && exit == old_exit)
		$env[:enter], $env[:exit] = enter.clamp(0.0, 1.0), exit.clamp(0.0, 1.0)
		yield
		$env[:enter], $env[:exit] = old_enter, old_exit
	end

	# Easy way to turn a fuzzy (0.0..1.0) to enter/exit values
	def with_enter_exit_progress(value)
		with_env(:enter, (value < 0.5) ? (value / 0.5) : 1.0) {
			with_env(:exit, (value > 0.5) ? ((value - 0.5) / 0.5) : 0.0) {
				yield
			}
		}
	end

	def with_env_hash(hash)
		old_values = Hash.new
		# Save current value, set new one
		hash.each_pair { |key, value| old_values[key] = $env[key] ; $env[key] = value }
		yield
		# Restore old values
		old_values.each_pair { |key, value| $env[key] = value }
	end
end
