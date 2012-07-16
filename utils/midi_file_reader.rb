require 'rubygems'
require 'midilib/io/seqreader'
require 'midilib/sequence'

class MIDIFileReader
	Sample = Struct.new(:time, :name, :value)

	attr_reader :samples, :beats_per_minute

	def initialize
		@samples = []
		@beats_per_minute = 120		# set for real when a file is loaded
	end

	$midi_key_channel_and_key_to_string ||= Hash.new { |channel_hash, channel_key| channel_hash[channel_key] = Hash.new { |note_hash, note_key| puts 'key' ; note_hash[note_key] = sprintf("MIDI / Channel %02d / Key %03d", channel_key, note_key) }}
	$midi_key_channel_and_slider_to_string ||= Hash.new { |channel_hash, channel_key| channel_hash[channel_key] = Hash.new { |slider_hash, slider_key| slider_hash[slider_key] = sprintf("MIDI / Channel %02d / Slider %03d", channel_key, slider_key) }}

	def load_file(file_path)
		return false unless File.exists? file_path

		start_time = Time.now.to_f

		# Create a new, empty sequence.
		seq = MIDI::Sequence.new()

		# Read the contents of a MIDI file into the sequence.
		File.open(file_path, 'rb') { |file|
			seq.read(file)
		}

		# Store this
		@beats_per_minute = seq.beats_per_minute

		samples_per_minute = (seq.beats_per_minute * seq.ppqn)
		samples_per_second = (samples_per_minute / 60.0)

		puts "MIDI format: #{seq.format}, BPM:#{seq.beats_per_minute}, Tempo:#{seq.tempo}, QNotes: #{seq.qnotes}, PPQN: #{seq.ppqn}, #{seq.numer}/#{seq.denom}, samples per second: #{samples_per_second}"

		sort_needed = false
		seq.each_with_index { |track, index|
			sort_needed = true if index > 0
			track.each { |event|
				case event
				when MIDI::NoteOn
					# ["<=>", "channel", "channel=", "channel_to_s", "data_as_bytes", "delta_time", "delta_time=", "note", "note=", "note_to_s", "number_to_s", "off", "off=", "pch_oct", "print_channel_numbers_from_one", "print_channel_numbers_from_one=", "print_decimal_numbers", "print_decimal_numbers=", "print_note_names", "print_note_names=", "quantize_to", "status", "time_from_start", "time_from_start=", "velocity", "velocity="]
					@samples << Sample.new(event.time_from_start / samples_per_second, $midi_key_channel_and_key_to_string[event.channel + 1][event.note], event.velocity / 127.0)

				when MIDI::NoteOff
					# ["<=>", "channel", "channel=", "channel_to_s", "data_as_bytes", "delta_time", "delta_time=", "note", "note=", "note_to_s", "number_to_s", "off", "off=", "pch_oct", "print_channel_numbers_from_one", "print_channel_numbers_from_one=", "print_decimal_numbers", "print_decimal_numbers=", "print_note_names", "print_note_names=", "quantize_to", "status", "time_from_start", "time_from_start=", "velocity", "velocity="]
					@samples << Sample.new(event.time_from_start / samples_per_second, $midi_key_channel_and_key_to_string[event.channel + 1][event.note], 0.0) 

				when MIDI::Controller
					# ["<=>", "channel", "channel=", "channel_to_s", "controller", "controller=", "data_as_bytes", "delta_time", "delta_time=", "number_to_s", "print_channel_numbers_from_one", "print_channel_numbers_from_one=", "print_decimal_numbers", "print_decimal_numbers=", "print_note_names", "print_note_names=", "quantize_to", "status", "time_from_start", "time_from_start=", "value", "value="]
					@samples << Sample.new(event.time_from_start / samples_per_second, $midi_key_channel_and_slider_to_string[event.channel + 1][event.controller], event.value / 127.0) 

				when MIDI::Tempo
					# ["<=>", "channel_to_s", "data", "data=", "data_as_bytes", "data_as_str", "delta_time", "delta_time=", "meta_type", "number_to_s", "print_channel_numbers_from_one", "print_channel_numbers_from_one=", "print_decimal_numbers", "print_decimal_numbers=", "print_note_names", "print_note_names=", "quantize_to", "status", "tempo", "tempo=", "time_from_start", "time_from_start="]
					#p event

				#when MIDI::TimeSig
					# ["<=>", "channel_to_s", "data", "data=", "data_as_bytes", "data_as_str", "delta_time", "delta_time=", "denominator", "measure_duration", "meta_type", "metronome_ticks", "number_to_s", "numerator", "print_channel_numbers_from_one", "print_channel_numbers_from_one=", "print_decimal_numbers", "print_decimal_numbers=", "print_note_names", "print_note_names=", "quantize_to", "status", "time_from_start", "time_from_start="]
				#when MIDI::KeySig
					# ["<=>", "channel_to_s", "data", "data=", "data_as_bytes", "data_as_str", "delta_time", "delta_time=", "major_key?", "meta_type", "minor_key?", "number_to_s", "print_channel_numbers_from_one", "print_channel_numbers_from_one=", "print_decimal_numbers", "print_decimal_numbers=", "print_note_names", "print_note_names=", "quantize_to", "sharpflat", "status", "time_from_start", "time_from_start="]
				#when MIDI::MetaEvent
					# ["<=>", "channel_to_s", "data", "data=", "data_as_bytes", "data_as_str", "delta_time", "delta_time=", "meta_type", "number_to_s", "print_channel_numbers_from_one", "print_channel_numbers_from_one=", "print_decimal_numbers", "print_decimal_numbers=", "print_note_names", "print_note_names=", "quantize_to", "status", "time_from_start", "time_from_start="]
				#when MIDI::ProgramChange
					# ["<=>", "channel", "channel=", "channel_to_s", "data_as_bytes", "delta_time", "delta_time=", "number_to_s", "print_channel_numbers_from_one", "print_channel_numbers_from_one=", "print_decimal_numbers", "print_decimal_numbers=", "print_note_names", "print_note_names=", "program", "program=", "quantize_to", "status", "time_from_start", "time_from_start="]

				end
			}
		}
		puts "Sorting Samples..." if sort_needed
		@samples.sort! { |s1, s2| s1.time <=> s2.time } if sort_needed
		puts "Loaded #{@samples.size} samples, first at #{@samples.empty? ? nil : @samples.first.time} in #{Time.now.to_f - start_time} seconds"
		return true
	end
end
