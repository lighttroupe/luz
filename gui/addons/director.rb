class Director
	easy_accessor :background_color, :default => [0,0,0,0.9]
	easy_accessor :gui_enter_exit_progress

	ENTER_EXIT_PROGESS_COLOR = [1.0,1.0,0.0,0.8]

	def gui_tick
		init_offscreen_buffer unless @offscreen_buffer
		update_offscreen_buffer! if update_offscreen_buffer?
	end

	def gui_render
		with_gui_object_properties {
			# Render as cached image
			with_image {
				with_scale(0.95,0.95) {
					unit_square
				}
			}
			if (pointer_hovering? || selected?) && @gui_enter_exit_progress > 0.0
				with_translation(0.0, -0.5 + 0.02) {
					with_scale(0.95,0.01) {
						with_color_listsafe(ENTER_EXIT_PROGESS_COLOR) {
							render_progress_bar_with_cache(@gui_enter_exit_progress)
						}
					}
				}
			end
		}
	end

	#
	# pointer
	#
	def click(pointer)
		if selected?
			super
		else
			@parent.set_selection(self)
			animate(:gui_enter_exit_progress, 0.5, 5.0)
		end
	end

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
		@offscreen_buffer.with_image { yield } if @offscreen_buffer		# otherwise doesn't yield
	end

	def update_offscreen_buffer?
		index = $engine.project.directors.index(self)
		@countdown ||= 3 + (index * 3)
		if @countdown == 0
			pointer_hovering? || selected?
		else
			@countdown -= 1
		end
	end

	def update_offscreen_buffer!
		with_enter_exit_progress(@gui_enter_exit_progress) {
			@offscreen_buffer.using { with_scale(0.625,1.0) { render! } }		# TODO: aspect ratio
		}
	end
end
