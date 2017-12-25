#
#
#
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
			with_image { unit_square }

			# enter/exit progress bar
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
		animate(:gui_enter_exit_progress, 0.5, 0.1)
		@parent.set_selection(@object)
		$gui.chosen_next_director = @object		# for playing live
	end
	def double_click(pointer)
		$gui.close_directors_menu!
		$gui.build_editor_for(@object, :pointer => pointer, :grab_keyboard_focus => true)
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
		index = $engine.project.directors.index(@object)
		@countdown ||= 3 + (index * 3)
		if @countdown == 0
			pointer_hovering? || selected?
		else
			@countdown -= 1
			false
		end
	end

	def update_offscreen_buffer!
		with_enter_exit_progress(@gui_enter_exit_progress) {
			@offscreen_buffer.using { with_scale(0.625,1.0) { @object.render! } }		# TODO: aspect ratio
		}
	end

	def scroll_down!(pointer)
		@gui_enter_exit_progress = (@gui_enter_exit_progress - 0.1).clamp(0.0,1.0)
	end
	def scroll_up!(pointer)
		@gui_enter_exit_progress = (@gui_enter_exit_progress + 0.1).clamp(0.0,1.0)
	end
end
