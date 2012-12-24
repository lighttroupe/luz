class Actor
	def gui_render!
		gui_render_background

		# Actor, render thyself!
		render!

		if pointer_hovering?
			with_translation(-0.35, -0.35) {
				with_scale(0.25, 0.25) {
					gui_render_label
				}
			}
		end
	end
end
