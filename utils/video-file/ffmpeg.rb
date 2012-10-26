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
	MAX_FRAME_CACHE_SIZE = 50

	class File
		attr_reader :frame_index
		def with_frame(index=0)
			@image ||= Image.new

			# loop index around on both sides
			index = index % self.frame_count if self.frame_count > 0		# sometimes it's 0?!

			#
			# Can we satisfy this from cache?
			#
			if(index == @last_frame_index || @last_frame_load == $env[:frame_number])
				#puts 'not moving forward'
			else
				# loop around?		TODO: this assumes video is moving forward
				if(index == 0 && @last_frame_index && @last_frame_index != 0)
					#puts 'seeking to 0'
					self.seek_to_frame(0)
				end

				if(new_data = self.read_next_frame)
					#puts "#{index} got frame"
					@image.from_rgb8(new_data, self.width, self.height)
				end

				@last_frame_index = index
				@last_frame_load = $env[:frame_number]
			end

			@image.using {
				yield
			}
		end

=begin
		def read_frame_index_into_image(index, image)
			if index != @frame_index
				#puts "#{index} seeking to"
				unless self.seek_to_frame(index)
					#puts "SEEKFAILED ==============================="
				end
				@frame_index = index
			end

			# Decode Frame
			if(new_data = self.read_next_frame)
				#puts "#{index} got frame"
				image.from_rgb8(new_data, self.width, self.height)
				@frame_index += 1
			else
				# Loop (TODO: this shouldn't be hit since we're correcting frame index above?)
				self.seek_to_frame(0)
				@frame_index = 0
			end
		end
=end
	end
end
