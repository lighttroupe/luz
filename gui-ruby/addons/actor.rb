class Actor
	def gui_render!
		gui_render_background

		# Actor, render thyself!
		with_image {
			unit_square
		}
#		render!

		if pointer_hovering?
			with_translation(-0.35, -0.35) {
				with_scale(0.25, 0.25) {
					gui_render_label
				}
			}
		end
	end

	def update_offscreen_buffer?
		pointer_hovering?
	end
end
