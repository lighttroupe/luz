require 'sample_player'

class DirectorEffectCueSheet < DirectorEffect
	virtual

	title				"Cue Sheet"
	description ""

	setting 'file', :string

	def after_load
		super
		@last_update_frame, @loaded_file_path, @cue_sheet, @sample_player = nil, nil, nil, nil
	end

	def tick
		#
		# Auto-start if this is the first tick
		#
		if (@last_update_frame.nil?) or (@last_update_frame < ($env[:frame_number] - 1))
			@start_time = $env[:frame_time]
		end

		#
		# Auto-reload if the file name has changed (and it exists)
		#
		if (file != @loaded_file_path)
			if (file_path=File.join($engine.project.file_path, file)) and File.exists? file_path
				@cue_sheet = CueSheet.new(file_path)
				@sample_player = SamplePlayer.new(@cue_sheet.samples)
				@sample_player.on_sample { |name, value| on_sample(name, value) }
				@loaded_file_path = file
			end
		end

		#
		# Update / send data to engine
		#
		delta_time = ($env[:frame_time] - @start_time)
		@sample_player.move_to_time(delta_time)

		@last_update_frame = $env[:frame_number]
	end

	def on_sample(name, value)
		#puts "#{name} = #{value}"

		case value
		when Integer
			$engine.on_button_up(name, 1)		# in either case
			$engine.on_button_down(name, 1) if value == 1

		when Float
			$engine.on_slider_change(name, value)
		else
			puts "warning: unhandled sample type (#{name} = #{value.class}##{value})"
		end
	end
end

class CueSheet
	attr_reader :samples

	def initialize(file_path)
		@samples = []
		load_file(file_path)
	end

private

	def load_file(file_path)
		return false unless File.exists? file_path

		# Save
		@file_path = file_path

		start_time = Time.now.to_f

		puts "Loading #{@file_path}..."

		# Read lines and parse
		data = File.read(file_path)
		puts "Read data..."
		data.split("\n").each_with_index { |line, index| parse_line(line, index+1) }

		#puts "Sorting Samples..." if sort_needed
		#@samples.sort! { |s1, s2| s1.time <=> s2.time } if sort_needed
		puts "Loaded #{@samples.size} samples in #{Time.now.to_f - start_time} seconds"

		return true
	end

	#puts "=" * 40
	#puts "= Cue File Error: #{@file_path}:#{line_number}: '#{line}'" unless parts == 3
	#puts "=" * 40

	def parse_line(line, line_number)
		parts = line.split(',')
		raise "line '#{line}' needs 3 parts" unless parts.size >= 3

		time, name, value = parts[0], parts[1], parts[2]

		@samples << SamplePlayer::Sample.new(parse_time(time), name.strip, parse_value(value))
	end

	def parse_time(time)
		# 4:58.04
		minutes_and_seconds, milliseconds = time.split('.')
		milliseconds ||= 0.0
		minutes, seconds = minutes_and_seconds.split(':')

		(minutes.to_f * 60.0) + (seconds.to_f) + (milliseconds.to_f / 100.0)
	end

	def parse_value(value)
		return value.to_f if value.include? '.'
		return value.to_i
	end
end
