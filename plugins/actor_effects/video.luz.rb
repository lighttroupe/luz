# Copyright 2012 Ian McIntosh

$video_files ||= {}

class ActorEffectVideoFile < ActorEffect
	title				"Video File"
	description ""

	setting 'file_name', :string

	def after_load
		require 'video-file/ffmpeg'
		super
	end

	def reload_if_needed
		if file_name != @file_name
			if $engine.project.file_path && File.exist? (path=File.join($engine.project.file_path, file_name))
				if (file = FFmpeg::File.new(path))
					@file = file
				end
			end
			@file_name = file_name
		end
	end

	def render
		reload_if_needed
		return yield unless @file

		@file.with_frame {
			yield
		}
	end
end
