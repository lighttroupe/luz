class GuiDirectorRenderer < GuiUserObjectRenderer
	ENTER_EXIT_PROGESS_COLOR = [1.0,1.0,0.0,0.8]

	attr_accessor :gui_enter_exit_progress		# (for animate below)

	def gui_render
		return if hidden?

		with_gui_object_properties {
			# Render as cached image
			@object.with_image {
				unit_square
			}

			with_translation(-0.23, -0.5 + 0.1) {
				with_scale(0.5,0.1) {
					gui_render_label
				}
			}
		}
	end

	def gui_tick
		@object.update_offscreen_buffer! if update_offscreen_buffer?
	end

	#
	# cached rendering (for live previews)
	#
	def update_offscreen_buffer?
		return true if pointer_hovering? || selected?

		directors = $engine.project.directors
		index = directors.index(@object)
		count = directors.count

		($env[:frame_number] % count) == index		# prevent rendering thumbnails too often
	end
end
