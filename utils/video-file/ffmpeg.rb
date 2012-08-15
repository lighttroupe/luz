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
		def with_frame(index=0)
			@frame_index ||= 0
			@last_frame_load ||= 0
			@frame_cache ||= {}

			# wrap index around (this works both positively and negatively)
			index = (index % self.frame_count) if index < 0 || index > (self.frame_count-1)

			# attempt to satisfy via cache?
			if(cache_hit = @frame_cache[index])
				puts "#{index} cache hit"
				cache_hit.using {
					yield
				}
				return
			end

			image = nil		# we will render with this image as texture

			# Reuse an existing image if if necessary
			if (@frame_cache.size >= MAX_FRAME_CACHE_SIZE)
				index_to_remove = @frame_cache.keys.random
				puts "#{index_to_remove} removing"
				image = @frame_cache.delete(index_to_remove)
			end

			# if we're still filling cache, make a new Image
			image ||= Image.new
			@frame_cache[index] = image

			# Get next frame
			if @last_frame_load < $env[:frame_number]
				read_frame_index_into_image(index, image)
				@last_frame_load = $env[:frame_number]
			end

			image.using {
				yield
			}
		end

		def read_frame_index_into_image(index, image)
			if index != @frame_index
				puts "#{index} seeking to"
				unless self.seek_to_frame(index)
					puts "SEEKFAILED ==============================="
				end
				@frame_index = index
			end

			# Decode Frame
			if(new_data = self.read_next_frame)
				puts "#{index} got frame"
				image.from_rgb8(new_data, self.width, self.height)
				@frame_index += 1
			else
				# Loop (TODO: this shouldn't be hit since we're correcting frame index above?)
				self.seek_to_frame(0)
				@frame_index = 0
			end
		end
	end
end
