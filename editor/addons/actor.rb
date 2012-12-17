class Actor
	def gui_render!
		gui_render_background
		render!

		# Label and shading effect
		if pointer_hovering?
			# TODO: add a shading helper
			with_translation(-0.35, -0.35) {
				with_scale(0.25, 0.25) {
					gui_render_label
				}
			}
		else
#			with_multiplied_alpha(0.5) {
#				gui_render_label
#			}
		end
	end
end
