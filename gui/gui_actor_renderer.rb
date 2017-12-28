class	GuiActorRenderer < GuiUserObjectRenderer
	ACTOR_COLOR = [1,1,1,1]

	def gui_render
		with_gui_object_properties {

			# Render as cached image
			with_color(ACTOR_COLOR) {
				@object.with_image {
					#with_scale(0.98, 0.98) {
						unit_square
					#}
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

	def gui_tick
		@object.update_offscreen_buffer! if update_offscreen_buffer?
	end

private

	def update_offscreen_buffer?
		true		# pointer_hovering?
	end
end
