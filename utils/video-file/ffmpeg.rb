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

			new_data = self.data
			@image.from_rgb8(new_data, self.width, self.height) if new_data

			@image.using {
				yield
			}
		end
	end
end
