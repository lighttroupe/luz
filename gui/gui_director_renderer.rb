class GuiDirectorRenderer < GuiUserObjectRenderer
	ENTER_EXIT_PROGESS_COLOR = [1.0,1.0,0.0,0.8]

	attr_accessor :gui_enter_exit_progress		# (for animate below)

	def gui_tick
		init_offscreen_buffer unless @offscreen_buffer
		update_offscreen_buffer! if update_offscreen_buffer?
	end

	def gui_render
		return if hidden?

		with_gui_object_properties {
			# Render as cached image
			with_image {
				unit_square
			}

			# enter/exit progress bar
			if (pointer_hovering? || selected?)
				if @gui_enter_exit_progress > 0.0
					with_translation(0.0, -0.5 + 0.02) {
						with_scale(0.95,0.01) {
							with_color_listsafe(ENTER_EXIT_PROGESS_COLOR) {
								render_progress_bar_with_cache(@gui_enter_exit_progress)
							}
						}
					}
				end
			end

			with_translation(-0.23, -0.5 + 0.1) {
				with_scale(0.5,0.1) {
					gui_render_label
				}
			}
		}
	end

	# mouse wheel shows enter/exit behavior in thumbnail
	def scroll_down!(pointer)
		@gui_enter_exit_progress = (@gui_enter_exit_progress - 0.1).clamp(0.0,1.0)
	end
	def scroll_up!(pointer)
		@gui_enter_exit_progress = (@gui_enter_exit_progress + 0.1).clamp(0.0,1.0)
	end

	#
	# cached rendering (for live previews)
	#
	def init_offscreen_buffer
		@gui_enter_exit_progress ||= 0.5
		@offscreen_buffer ||= get_offscreen_buffer(:medium)
	end

	def with_image
		return unless @offscreen_buffer		# otherwise doesn't yield
		@offscreen_buffer.with_image { yield }
	end

	def update_offscreen_buffer?
		return true if pointer_hovering? || selected?

		directors = $engine.project.directors
		index = directors.index(@object)
		count = directors.count

		($env[:frame_number] % count) == index		# prevent rendering thumbnails too often
	end

	def update_offscreen_buffer!
		with_enter_exit_progress(@gui_enter_exit_progress) {
			@offscreen_buffer.using { with_scale(0.625,1.0) { @object.render! } }		# TODO: aspect ratio
		}
	end
end
