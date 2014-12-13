class Actor
	ACTOR_COLOR = [1,1,1,1]

	def gui_render!
		with_gui_object_properties {

			# Render as cached image
			with_color(ACTOR_COLOR) {
				with_image {
					unit_square
				}
			}

			# Label
			if pointer_hovering?
				with_translation(0.0, -0.35) {
					with_scale(1.0, 0.25) {
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
		@offscreen_buffer ||= get_offscreen_buffer(:medium)
	end

	def with_image
		@offscreen_buffer.with_image { yield } if @offscreen_buffer		# otherwise doesn't yield
	end

	def update_offscreen_buffer!
		@offscreen_buffer.using { render! }
	end
end
