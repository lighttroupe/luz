module AL
	class Buffer
		attr_accessor :sample_player
	end

	class Source
		attr_accessor :id, :chosen_pitch, :chosen_gain, :last_frame_number_update, :buffer
		boolean_accessor :dying
	end
end

optional_require 'midi_file_reader'
require 'sample_player'
require 'ruby_version'			# loads different binding for 1.8 and 1.9 in init_openal

class SoundManager
	POSITION_MULTIPLIER = 2.0
	LISTENER_Z = 0.0		# puts listener right in the action
	DEFAULT_SOURCE_REFERENCE_DISTANCE = 0.01
	DEFAULT_SOURCE_ROLLOFF = 1.0

	def initialize
		@file_path_to_buffer = Hash.new
		@available_sources = []
		@active_sources = []
		@id_to_source_hash = {}
		@next_id = 0
		@global_pitch = 1.0
		init_openal
	end

	def print_openal_instructions
		puts '=' * 40
		puts '='
		puts '= Unable to initialize sound: please run build script in utils/openal'
		puts '='
		puts '=' * 40
	end

	def init_openal
		begin
			require "openal/#{ruby_version[0]}.#{ruby_version[1]}/openal"
		rescue LoadError
			# If we're on 1.8 also try the old location
			if ruby_version[1] == 8
				begin
					require "openal/openal"
				rescue LoadError
					print_openal_instructions
					raise
				end
			else
				print_openal_instructions
				raise
			end
		end

		ALUT.init
		puts "#{AL.string(AL::RENDERER)} #{AL.string(AL::VERSION)}"
		print_al_error('ALUT.init')

		if enable_efx?
			@auxiliary_effect_slot = AL::AuxiliaryEffectSlot.new

			@filter_lowpass = AL::Filter.new
			@filter_lowpass.filter_type = AL::Filter::FILTER_LOWPASS

			load_audio_environments
		end

		#
		# 
		#
		AL::Listener.position = [0.0, 0.0, LISTENER_Z]
		print_al_error('AL::Listener.position=')
		AL::Listener.orientation = [0.0, 0.0, -1.0, 0.0,1.0,0.0]		# pointed 'at' (relative to listener), head 'up' positive Y
		print_al_error('AL::Listener.orientation=')

		#AL.distance_model = AL::INVERSE_DISTANCE_CLAMPED
		AL.speed_of_sound = 1.0		# units per second
	end

	def load_file(file_path)		# NOTE: file path does not include extensions
		available_formats = []
		# find all available formats
		Dir.glob(File.join($engine.project.file_path, file_path+'*')) { |p|
			available_formats << p
		}
		return nil if available_formats.empty?

		# load, in order of preference: ogg, wav
		buffer = nil
		if available_formats.include?(filepath=File.join($engine.project.file_path, file_path+'.ogg'))
			timer("load #{filepath}", :if_over => 0.1) {
				buffer = AL::Buffer.load_from_ogg_file(filepath)
			}
		elsif available_formats.include?(filepath=File.join($engine.project.file_path, file_path+'.wav'))
			buffer = AL::Buffer.load_from_file(filepath)
		end

		# also load MIDI samples for this buffer?
		if defined? MIDIFileReader
			reader = MIDIFileReader.new
			if reader.load_file(File.join($engine.project.file_path, file_path+'.mid'))
				sample_player = SamplePlayer.new(reader.samples, offset = 1.60)		# TODO: offset ??
				sample_player.on_sample(&method(:on_sample))
				buffer.sample_player = sample_player

				# TODO: we only want this for the main music track, and better aligned to the beat
				$engine.beats_per_minute = reader.beats_per_minute
				$engine.next_beat_is_zero!
			end
		end
		return buffer
	end

	def on_sample(name, value)
		$engine.on_slider_change(name, value)
	end

	def next_id
		@next_id += 1
	end

	def global_pitch=(new_pitch)
		return if new_pitch == @global_pitch or new_pitch < 0.01 #or new_pitch > 100
		@global_pitch = new_pitch
		@active_sources.each { |source| source.pitch = pitch_for_source(source) }
	end

	def print_al_error(location='')
		e = AL.get_error
		puts "AL.get_error (after '#{location}') = #{e} ('#{AL.string(e)}')" unless e == AL::NO_ERROR
	end

	GAIN_FADE_STEP = 0.05		# 5% is inaudibly-close

	def tick!
#		@@once ||= 1
#					set_environment('chapel') if (@@once -= 1) == 0

		#
		# Manage active sources, move to available sources stack if done
		#
		#puts "Active Sources: #{@active_sources.count}"
		@active_sources.delete_if { |source|
			if source.playing?
				if (sample_player=source.buffer.sample_player)
					time = (source.sample_offset.to_f / source.buffer.frequency.to_f)
					sample_player.move_to_time(time)
				end

				# Fading-out?
				if (source.dying? or (source.looping and ($env[:frame_number] - source.last_frame_number_update) > 5))
					if source.gain <= 0.0
						recycle_source(source)
						true		# delete from active_sources array
					else
						#puts "fading out #{source.id}"
						source.gain = (source.gain < GAIN_FADE_STEP) ? (0.0) : (source.gain - GAIN_FADE_STEP)		# TODO: something more dynamic?
						false		# keep
					end

				elsif source.gain != source.chosen_gain
					gain_delta = (source.chosen_gain - source.gain)
					source.gain = (gain_delta.abs < GAIN_FADE_STEP) ? (source.chosen_gain) : (source.gain + (gain_delta > 0 ? GAIN_FADE_STEP/4 : -GAIN_FADE_STEP/4))
					false		# keep

				else
					false		# keep normally playing sound
				end
			else
				# single-play sound has stopped on its own
				recycle_source(source)
				true		# delete from active_sources array
			end
		}
	end

	def volume=(v)
		AL::Listener.gain = v
	end

	def new_source
		return @available_sources.pop unless @available_sources.empty?
		return AL::Source.new
	end

	def listener_position=(a)
		AL::Listener.position = [a[0], a[1], LISTENER_Z]	# TODO: TEMPORARY ? pass in current follow_body layer's Z ? 
	end

	def play(file_path, options={})
		#$stderr.puts "playing #{file_path} at #{options[:at]}..."

		unless (buffer=@file_path_to_buffer[file_path])
			buffer = @file_path_to_buffer[file_path] = load_file(file_path)
		end
		return puts "sound-manager: failed to load sound #{file_path}" unless buffer

		source = new_source ; print_al_error('new_source')
		source.attach(buffer) ; print_al_error('source.attach')
		source.buffer = buffer
		#$engine.next_beat_is_zero! if buffer.sample_player

		# for sweeping of unmaintained sources
		source.last_frame_number_update = $env[:frame_number]
		source.dying = false

		source.chosen_gain = (options[:volume] || 1.0)
		source.gain = (options[:fade_in] ? 0.0 : source.chosen_gain)

		source.chosen_pitch = (options[:pitch] || 1.0)
		source.pitch = pitch_for_source(source)

		if enable_efx?
			# setup filter
			@filter_lowpass.lowpass_gain = 1.0
			@filter_lowpass.lowpass_gainhf = 1.0	#((1.0 - (sound_event.occlusion || 0.0)).squared)

			# stamp filter on the dry-path
			source.direct_filter = @filter_lowpass

			# stamp filter on the wet path, and point it at the Auxiliary Effect Slot
			source.auxiliary_send_filter(@auxiliary_effect_slot, @filter_lowpass)
		end

		source.rolloff_factor = options[:rolloff] || DEFAULT_SOURCE_ROLLOFF
		source.reference_distance = DEFAULT_SOURCE_REFERENCE_DISTANCE

		# Feature: positional audio using :at => object_that_responds_to_x_and_y
		if (position=options[:at])
			puts "sound-manager: warning: positional sound is not mono #{file_path}" if buffer.channels != 1

			source.position = [position.x, position.y, 0.0]
			source.source_relative = false		# no, world origin relative
		else
			source.position = [0.0, 0.0, 0.0]
			source.source_relative = true			# yes, relative to listener position
		end

		@active_sources << source

		# press play...
		if options[:looping]
			source.looping = 1
			source.id = next_id
			@id_to_source_hash[source.id] = source
			source.play
			print_al_error('source.play (looping)')
			return source.id
		else
			source.looping = 0
			source.play
			print_al_error('source.play')
			return nil
		end
	end

	#
	# Updating by sound id
	#
	def valid_id?(id)
		!(@id_to_source_hash[id].nil?)
	end

	def update_position(id, position)
		return unless (source = @id_to_source_hash[id])
		source.position = [position.x, position.y, 0.0]
		print_al_error('update_position{source.position=}')
		source.last_frame_number_update = $env[:frame_number]
	end

	def update_pitch(id, pitch)
		return unless (source = @id_to_source_hash[id])
		source.chosen_pitch = pitch
		source.pitch = pitch_for_source(source)
		print_al_error('update_pitch{source.pitch=}')
		source.last_frame_number_update = $env[:frame_number]
	end

	def pitch_for_source(source)
		(source.chosen_pitch * @global_pitch)
	end

	def update_volume(id, volume)
		return unless (source = @id_to_source_hash[id])
		source.chosen_gain = volume
		source.last_frame_number_update = $env[:frame_number]
	end

	# fade out sound
	def stop_by_id(id)
		return unless (source = @id_to_source_hash[id])
		#puts "SoundManager::stop_by_id(#{id}) = #{source}"
		source.dying = true
	end

	# immediately remove sound
	def remove_by_id(id)
		return unless (source = @id_to_source_hash[id])
		#puts "SoundManager::remove_by_id(#{id})"
		@active_sources.delete(source)
		recycle_source(source)
	end

#	def stop_all
#		@active_sources.delete_if { |source|
#			# detach source and move it to available queue
#			source.stop
#			source.attach(0)
#			@available_sources << source
#			true
#		}
#	end

	# millibels (1/1000ths of a decible) to gain 0.0->1.0
	def mB2gain(n)
		10.0**(n/2000.0)
	end

	def load_audio_environments
		@audio_environments = {}
		filename = File.join("audio-environments.csv")
		File.open(filename).each_line { |line|
			c = line.split(',')
			name = c[0].gsub(' ','-').downcase

			# Extract the relevant values from the table (column order chosen by
			@audio_environments[name] = {
				:reverb_density => (1.0), # / 100.0),
				:reverb_diffusion => (c[3].to_f / 100.0),
				:reverb_gain => mB2gain(c[4].to_f),
				:reverb_gainhf => mB2gain(c[5].to_f) * 0.5,
				:reverb_decay_time => c[7].to_f,
				:reverb_decay_hfratio => c[8].to_f,
				:reverb_reflections_gain => mB2gain(c[10].to_f) * 0.5,
				:reverb_reflections_delay => c[11].to_f,
				:reverb_late_reverb_gain => mB2gain(c[15].to_f) * 0.3,		# lowering this value seems to alleviate the 'rattle' sound of some reverb environments
				:reverb_late_reverb_delay => c[16].to_f,
				#:reverb_air_absorption_gainhf => mB2gain(c[5].to_f) * 0.5,
				:reverb_room_rolloff_factor => c[28].to_f * 0.5,
				:reverb_decay_hflimit => true
			}
		}
		puts "Loaded #{@audio_environments.size} audio environments."
	end

	def enable_efx?
		true
	end

	attr_reader :audio_environment_name
	def set_environment(name)
		return unless enable_efx?
		return if name == @audio_environment_name

		if name
			if @audio_environments[name]
				@effect_environment = AL::Effect.new
				print_al_error('AL::Effect.new')
				@effect_environment.effect_type = AL::Effect::EFFECT_REVERB
				print_al_error('AL::Effect#effect_type=')

				@audio_environments[name].each { |key, value|
					@effect_environment.send("#{key}=", value)
					print_al_error("@effect_environment.#{key}=#{value}")
				}

				@auxiliary_effect_slot.effect = @effect_environment
				print_al_error('@auxiliary_effect_slot.effect=')

				@audio_environment_name = name
				return true

				#puts "audio-manager: set audio environment: #{name}"
			else
				puts "audio-manager: environment missing (name: #{name})"
				# keep using the same one
				return false
			end
		else
			@auxiliary_effect_slot.effect = nil
			@audio_environment_name = nil
			return true
		end
	end

private

	def recycle_source(source)
		source.stop
		source.attach(0)
		@id_to_source_hash.delete(source.id) if source.id
		@available_sources << source
	end
end
