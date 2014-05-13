module EngineEnvironment
	def init_environment
		$env[:time] = 0.0
		$env[:beat] = 0.0
		$env[:output_width] = $application.width
		$env[:output_height] = $application.height

		# Because of the nature of with_x { } blocks, we only need to set some things once
		# NOTE: an editor GUI *can* mess with these values, though, and this is intentional!

		$env[:last_message_bus_activity_at] = nil					# set by message bus
		$env[:time_since_message_bus_activity] = 999.0		# like fo'eva

		# Default enter/exit is right in the middle (fully on stage)
		$env[:enter] = 1.0
		$env[:exit] = 0.0
	end

	def update_environment
		beat_scale = @beat_detector.progress			# a fuzzy (0.0 to 1.0 inclusive) measure of progress within the current beat
		bpm = @beat_detector.beats_per_minute

		# Integer beat counts
		$env[:beat_number] = @beat_detector.beat_number					# integer beat count
		$env[:beats_per_measure] = @beat_detector.beats_per_measure					# integer beat count
		$env[:beat_index_in_measure] = $env[:beat_number] % $env[:beats_per_measure]

		# Integer measure count
		$env[:measure_number] = $env[:beat_number].div($env[:beats_per_measure])				# TODO: account for measure changes ?

		# Floating point measure scale (0.0 to 1.0)
		$env[:measure_scale] = ($env[:beat_index_in_measure] + beat_scale) / $env[:beats_per_measure]

		# Floating point measure number (eg. measure 503.2)
		$env[:measure] = $env[:measure_number] + $env[:measure_scale]

		# Floating point beat scale (0.0 to 1.0)
		$env[:previous_beat_scale] = $env[:beat_scale]		# TODO: does this need to be initialized for frame 0?
		$env[:beat_scale] = beat_scale						# fuzzy beat (0.0 to 1.0)

		# Floating point beat count (eg. beat 2012.8)
		$env[:previous_beat] = $env[:beat]
		$env[:beat] = ($env[:beat_number] + beat_scale)
		$env[:beat_delta] = ($env[:beat] - $env[:previous_beat])

		$env[:is_beat] = @beat_detector.is_beat?	# boolean
		$env[:bpm] = bpm
		$env[:bps] = bpm / 60.0
		$env[:seconds_per_beat] = 60.0 / bpm
		$env[:frame_number] = @frame_number

		$env[:previous_time] = $env[:time]
		$env[:time] = @time
		$env[:time_delta] = @time_delta

		$env[:frame_time] = @frame_time						# TODO: change to 'real world time' or something
		$env[:frame_time_delta] = @frame_time_delta

		# Default birth times: beginning of engine time
		$env[:birth_time] = 0.0
		$env[:birth_beat] = 0

		$env[:child_index] = 0
		$env[:total_children] = 1

		$env[:time_since_message_bus_activity] = ($env[:frame_time] - $env[:last_message_bus_activity_at]) if $env[:last_message_bus_activity_at]
	end
end
