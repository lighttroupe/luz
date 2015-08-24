$video_files ||= {}
require 'video_file/ffmpeg'

class ActorEffectVideoFile < ActorEffect
	title				"Video File"
	description ""

	categories :color

	setting 'file_name', :string
	setting 'speed', :float, :range => 0.0..10.0, :default => 1.0..1.0

	setting 'jump_frames', :integer, :range => 10..10000
	setting 'jump_forward', :event
	setting 'jump_backward', :event

	def after_load
		@frame_index = 0.0		# NOTE: float
		super
	end

	def tick
		reload_if_needed
		@frame_index ||= 0
		@frame_index += (speed)

		#@skip_frames += jump_frames if jump_forward.now?
		#@skip_frames -= jump_frames if jump_backward.now?
		#@frame_index += (1 + @skip_frames)
	end

	def render
		return yield unless @file

		frame_index_integer, remainder = @frame_index.divmod(1.0)

		@file.with_frame(frame_index_integer) {
			yield
		}

		#@frame_index = @file.frame_index - 1		# since it progresses automatically after reading the next frame
		#@skip_frames = 0
	end

private

	def reload_if_needed
		if file_name != @file_name
			if $engine.project.file_path
				path = File.join($engine.project.file_path, file_name)
				@file = FFmpeg::File.new(path) if File.file?(path)
			end
			@file_name = file_name
		end
	end
end
