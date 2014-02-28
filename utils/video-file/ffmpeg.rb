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

#
# Provides caching and a cleaner interface on top of the basic read and seek C backend
#
module FFmpeg
	class File
		def with_frame(index=0)
			@image ||= Image.new
			@index ||= 0

			# loop index around on both sides
			index = index % self.frame_count if self.frame_count > 0		# sometimes it's 0?!

			delta = (index - @index)
			#puts "delta = #{delta}"
			if index == 0 || delta < 0 || delta > 10
				seek_to_frame(index) or puts 'video-file: seek failed'
			else
				# Reading and decoding multiple frames-- is there a more effecient way?
				delta.times { read_next_frame_into_image(@image) }		# (possibly 0)
			end
			@index = index

			@image.using {
				yield
			}
		end

		def read_next_frame_into_image(image)
			#puts "reading next frame" 
			new_data = read_next_frame
			#puts "video-file: read_next_frame failed" unless new_data
			image.from_rgb8(new_data, self.width, self.height) if new_data
		end
	end
end
