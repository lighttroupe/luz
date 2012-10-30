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
		attr_reader :frame_index
		def with_frame(index=0)
			@image ||= Image.new

			# loop index around on both sides
			index = index % self.frame_count if self.frame_count > 0		# sometimes it's 0?!

			if(index == @last_frame_index || @last_frame_load == $env[:frame_number])
				#puts 'not moving forward'
			else
				# loop around?		TODO: this assumes video is moving forward
				if(index == 0 && @last_frame_index && @last_frame_index != 0)
					#puts 'seeking to 0'
					if self.seek_to_frame(0)
						#puts 'video-file: seeked to 0'
					else
						puts 'video-file: seek failed'
					end
				end

				if(new_data = self.read_next_frame)
					#puts "got frame #{index}"
					@image.from_rgb8(new_data, self.width, self.height)
				else
					puts "video-file: read_next_frame failed"
				end

				@last_frame_index = index
				@last_frame_load = $env[:frame_number]
			end

			@image.using {
				yield
			}
		end
	end
end
