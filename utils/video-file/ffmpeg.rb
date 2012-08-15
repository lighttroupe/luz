direc = File.dirname(__FILE__)
dlext = Config::CONFIG['DLEXT']
begin
	if RUBY_VERSION && RUBY_VERSION =~ /1.9/
		require "#{direc}/1.9/ffmpeg.#{dlext}"
	else
		require "#{direc}/1.8/ffmpeg.#{dlext}"
	end
rescue LoadError => e
	require "#{direc}/ffmpeg.#{dlext}"
end

module FFmpeg
	class File
		def with_frame(offset=0)
			@image ||= Image.new
			@frame_index ||= 0
			@last_frame_load ||= 0

			# Get next frame
			if @last_frame_load < $env[:frame_number]
				if(new_data = self.read_next_frame)
					@image.from_rgb8(new_data, self.width, self.height)
					@frame_index += 1
				else
					self.seek_to_frame(0)
					@frame_index = 0
				end
				@last_frame_load = $env[:frame_number]
			end

			@image.using {
				yield
			}
		end
	end
end
