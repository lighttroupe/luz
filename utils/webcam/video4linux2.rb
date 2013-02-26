direc = File.dirname(__FILE__)
dlext = Config::CONFIG['DLEXT']
begin
	if RUBY_VERSION && RUBY_VERSION =~ /1.9/
		require "#{direc}/1.9/video4linux2.#{dlext}"
	else
		require "#{direc}/1.8/video4linux2.#{dlext}"
	end
rescue LoadError => e
	require "#{direc}/video4linux2.#{dlext}"
end

module Video4Linux2
	class Camera
		def with_frame(offset=0)
			@image ||= Image.new
			@width ||= self.width
			@height ||= self.height

			new_data = self.data
			@image.from_rgb8(new_data, @width, @height) if new_data

			@image.using {
				yield
			}
		end
	end
end
