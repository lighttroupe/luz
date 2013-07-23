class Director
	easy_accessor :background_color, :default => [0,0,0,0.9]

	def gui_render!
		with_gui_object_properties {
			# Render as cached image
			with_image {
				with_scale(0.95,0.95) {
					unit_square
				}
			}
		}
	end

	def gui_tick!
		init_offscreen_buffer
		update_offscreen_buffer! if update_offscreen_buffer?
	end

	def update_offscreen_buffer?
		true		#pointer_hovering?
	end

	def init_offscreen_buffer
		@offscreen_buffer ||= get_offscreen_buffer(framebuffer_image_size)
	end

	def framebuffer_image_size
		:medium		# see drawing_framebuffer_objects.rb
	end

	def with_image
		@offscreen_buffer.with_image { yield } if @offscreen_buffer		# otherwise doesn't yield
	end

	def update_offscreen_buffer!
		@offscreen_buffer.using { render! }
	end
end
