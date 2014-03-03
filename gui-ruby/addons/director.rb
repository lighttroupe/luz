class Director
	easy_accessor :background_color, :default => [0,0,0,0.9]

	def gui_render!
		with_gui_object_properties {
			# Render as cached image
			with_image {
				with_scale(0.95,0.95) {
					unit_square
				}
			}
			if pointer_hovering? && @gui_enter_exit_progress != 0.0
				with_translation(0.0, -0.5 + 0.02) {
					with_scale(0.95,0.01) {
						render_bar(@gui_enter_exit_progress)
					}
				}
			end
		}
	end

	VALUE_COLOR = [1.0,1.0,0.0,0.8]

	def render_bar(value)
		if value > 0.0
			with_translation(-0.5 + value/2.0, 0.0) {
				with_scale_unsafe(value, 1.0) {
					with_color_listsafe(VALUE_COLOR) {
						unit_square
					}
				}
			}
		end
	end

	easy_accessor :gui_enter_exit_progress

	def click(pointer)
		if selected?
			super
		else
			@parent.set_selection(self)
			animate(:gui_enter_exit_progress, 0.5, 5.0)
		end
	end

	def scroll_down!(pointer)
		#clear_animations_for_field!(:gui_enter_exit_progress)
		@gui_enter_exit_progress = (@gui_enter_exit_progress - 0.1).clamp(0.0,1.0)
	end
	def scroll_up!(pointer)
		#clear_animations_for_field!(:gui_enter_exit_progress)
		@gui_enter_exit_progress = (@gui_enter_exit_progress + 0.1).clamp(0.0,1.0)
	end

	def gui_tick!
		init_offscreen_buffer
		update_offscreen_buffer! if update_offscreen_buffer?
	end

	def update_offscreen_buffer?
		index = $engine.project.directors.index(self)
		@countdown ||= 3 + (index * 3)
		if @countdown == 0
			pointer_hovering? || selected?
		else
			($env[:frame_number] % $engine.project.directors.count) == index
			@countdown -= 1
		end
		#@last_update ||= rand(3)
		#return false unless $env[:frame_number] - @last_update > 3
		#@last_update = $env[:frame_number]
		#true
		#pointer_hovering?
	end

	def init_offscreen_buffer
		@gui_enter_exit_progress ||= 0.5
		@offscreen_buffer ||= get_offscreen_buffer(framebuffer_image_size)
	end

	def framebuffer_image_size
		:medium		# see drawing_framebuffer_objects.rb
	end

	def with_image
		@offscreen_buffer.with_image { yield } if @offscreen_buffer		# otherwise doesn't yield
	end

	def update_offscreen_buffer!
		#p "#{self} updating on frame #{$env[:frame_number]}"
		with_enter_exit_progress(@gui_enter_exit_progress) {
			@offscreen_buffer.using { with_scale(0.625,1.0) { render! } }		# TODO: aspect ratio
		}
	end
end
