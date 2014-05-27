#
# SDL handles graphics system init, timing, and sleeping in a cross-platform way
#
# http://www.libsdl.org
#
class SDLApplication
	include Drawing

	attr_accessor :width, :height, :fullscreen, :border, :bits_per_pixel, :frames_per_second
	boolean_accessor :finished
	boolean_accessor :system_mouse

	def initialize(name)
		@name, @width, @height, @bits_per_pixel = name, 0, 0, 0		# NOTE: setting bpp to 0 means "current" in SDL
		@fullscreen = true
		@stencil_buffer = true
		@border = true

		# Frame rate should, ideally, match that of LCD, projector, etc.
		# TODO: add an option for syncing to output device refresh rate, as a way to limit refresh rate.
		@frames_per_second = 60
	end

	def create
		init_sdl
		set_video_mode
		init_gl_viewport
	end

	def toggle_fullscreen!
		@fullscreen = !@fullscreen
		set_video_mode
		init_gl_viewport
	end

	#
	# Main Loop
	#
	def run
		start_time_ms = SDL.getTicks
		frame_number = 1

		while not finished?
			desired_ms_per_frame = (1000 / @frames_per_second)		# NOTE: desired FPS can change at any time

			frame_start_ms = SDL.getTicks
			age_in_seconds = (frame_start_ms - start_time_ms) / 1000.0

			while event = SDL::Event2.poll
				handle_sdl_event(event)
			end

			do_frame(age_in_seconds)

			SDL.GL_swap_buffers

			frame_duration_ms = SDL.getTicks - frame_start_ms

			# sleep a bit...
			sleep_time_ms = desired_ms_per_frame - frame_duration_ms
			SDL.delay(sleep_time_ms) if sleep_time_ms > 3		# for tiny amounts it doesn't make sense

			frame_number += 1

			after_update
		end
		SDL.quit
		after_run((SDL.getTicks - start_time_ms) / 1000.0)
	end

	#
	# Screenshots
	#
	def get_framebuffer_rgb
		GL.Flush
		GL.ReadPixels(0, 0, @width, @height, GL::RGB, GL::UNSIGNED_BYTE)
	end

	def save_framebuffer_to_file(path)
		image = Magick::Image.new(width, height)
		image.import_pixels(0, 0, width, height, "RGB", get_framebuffer_rgb, Magick::CharPixel)
		image.flip!			# data comes at us upside down
		image.write(path)
	end

private

	def init_sdl
		puts "Using SDL version #{SDL::VERSION}"
		SDL.init(SDL::INIT_VIDEO | SDL::INIT_TIMER)

		# Window
		SDL::WM.set_caption(@name, '')

		# Keyboard
		SDL::Key.disable_key_repeat		# We want one Down and one Up message per key press

		# Mouse
		hide_mouse unless system_mouse?
	end

	def hide_mouse
		# NOTE: using a blank cursor works better than SDL::Mouse.hide with Wacom tablets
		SDL::Mouse.setCursor(SDL::Surface.new(SDL::HWSURFACE,8,8,8,0,0,0,0),1,1,0,1,0,0)
	end

	def set_video_mode
		SDL.setGLAttr(SDL::GL_STENCIL_SIZE, 8) if @stencil_buffer
		@screen = SDL.set_video_mode(@width, @height, @bits_per_pixel, sdl_video_mode_flags)

		# See what we got
		@width, @height = @screen.w, @screen.h
		@bits_per_pixel = @screen.bpp if @bits_per_pixel == 0

		puts "Running at #{@width}x#{@height} @ #{@bits_per_pixel}bpp, #{@frames_per_second}fps (max)"
	end

	def sdl_video_mode_flags
		flags = SDL::HWSURFACE | SDL::OPENGL
		flags |= SDL::FULLSCREEN if @fullscreen
		flags |= SDL::RESIZABLE if !@fullscreen
		flags |= SDL::NOFRAME unless @border
		flags
	end

	def init_gl_viewport
		GL.Viewport(0, 0, @width, @height)
		clear_screen([0.0, 0.0, 0.0, 0.0])
	end
end
