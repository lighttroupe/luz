module Video4Linux2
	class Camera
		def with_frame(offset=0)
			@image ||= Image.new

			@image.from_rgb8($webcam.data, self.width, self.height)

			@image.using {
				yield
			}
		end
	end
end
