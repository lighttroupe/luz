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
