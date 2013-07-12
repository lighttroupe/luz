class Actor
	ACTOR_COLOR = [1,1,1,1]

	def background_image
		@background_image ||= $engine.load_image('images/actor-background.png').set_texture_options(:no_smoothing => true)
	end

	def gui_render!
		with_gui_object_properties {

			# Checkerboard background
			#background_image.using {
				#unit_square
			#}

			# Render as cached image
			with_color(ACTOR_COLOR) {
				with_image {
					unit_square
				}
			}

			# Label
			if pointer_hovering?
				with_translation(-0.35, -0.35) {
					with_scale(0.25, 0.25) {
						gui_render_label
					}
				}
			end
		}
	end

	def gui_tick!
		init_offscreen_buffer
		update_offscreen_buffer! if update_offscreen_buffer?
	end

	def update_offscreen_buffer?
		true		# pointer_hovering?
	end

	#
	# ...
	#
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
