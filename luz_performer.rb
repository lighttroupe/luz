class LuzPerformer
	include Drawing

	SDL_TO_LUZ_BUTTON_NAMES = {'`' => 'Grave', '\\' => 'Backslash', '[' => 'Left Bracket', ']' => 'Right Bracket', ';' => 'Semicolon', "'" => 'Apostrophe', '/' => 'Slash', '.' => 'Period', ',' => 'Comma', '-' => 'Minus', '=' => 'Equal', 'left ctrl' => 'Left Control', 'right ctrl' => 'Right Control'}

	attr_accessor :width, :height, :fullscreen, :border, :bits_per_pixel, :frames_per_second
	boolean_accessor :finished, :escape_quits

	TIMING_COUNT = 10

	def initialize
		@width, @height, @bits_per_pixel = 0, 0, 0		# NOTE: setting bpp to 0 means "current" in SDL
		@fullscreen = true
		@stencil_buffer = true
		@border = true

		self.escape_quits = true

		# Frame rate should, ideally, match that of LCD, projector, etc.
		# TODO: add an option for syncing to output device refresh rate, as a way to limit refresh rate.
		@frames_per_second = 60
	end

	def toggle_fullscreen!
		@fullscreen = !@fullscreen
		set_video_mode
		init_gl_viewport
	end

	def create
		init_sdl
		set_video_mode
		init_gl_viewport
	end

	def init_sdl
		puts "Using SDL version #{SDL::VERSION}"
		SDL.init(SDL::INIT_VIDEO | SDL::INIT_TIMER)

		# Window
		SDL::WM.set_caption(APP_NAME, '')

		# Keyboard
		SDL::Key.disable_key_repeat		# We want one Down and one Up message per key press

		# Mouse
		# NOTE: using a blank cursor works better than SDL::Mouse.hide with Wacom pads
		SDL::Mouse.setCursor(SDL::Surface.new(SDL::HWSURFACE,8,8,8,0,0,0,0),1,1,0,1,0,0)
	end

	def set_video_mode
		SDL.setGLAttr(SDL::GL_STENCIL_SIZE, 8) if @stencil_buffer
		@screen = SDL.set_video_mode(@width, @height, @bits_per_pixel, sdl_video_mode_flags)

		# Save
		@width, @height = @screen.w, @screen.h
		@bits_per_pixel = @screen.bpp if @bits_per_pixel == 0

		puts "Running at #{@screen.w}x#{@screen.h} @ #{@bits_per_pixel}bpp, #{@frames_per_second}fps (max)"
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

	#
	# Some hacks for reduced garbage / better performance
	#
	MOUSE_1_X = "Mouse 01 / X"
	MOUSE_1_Y = "Mouse 01 / Y"

	MOUSE_BUTTON_FORMAT = "Mouse %02d / Button %02d"
	Mouse_1_button_formatter = Hash.new { |hash, key| hash[key] = sprintf(MOUSE_BUTTON_FORMAT, 1, key) }

	def parse_event(event)
		case event
		# Mouse input
		when SDL::Event2::MouseMotion
			$engine.on_slider_change(MOUSE_1_X, (event.x / (@width - 1).to_f))
			$engine.on_slider_change(MOUSE_1_Y, (1.0 - (event.y / (@height - 1).to_f)))

		when SDL::Event2::MouseButtonDown
			$engine.on_button_down(Mouse_1_button_formatter[event.button], frame_offset=1)

		when SDL::Event2::MouseButtonUp
			$engine.on_button_up(Mouse_1_button_formatter[event.button], frame_offset=1)

		# Keyboard input
		when SDL::Event2::KeyDown
			if event.sym == SDL::Key::ESCAPE and escape_quits?
				#toggle_fullscreen!
				finished!
			else
				key_name = SDL::Key.get_key_name(event.sym)
				$engine.on_button_down(sdl_to_luz_button_name(key_name), 1)	# 1 is frame_offset: use it on the coming frame
				$gui.raw_keyboard_input(sdl_to_gui_key(key_name, event)) if $gui
			end

		when SDL::Event2::KeyUp
			$engine.on_button_up(sdl_to_luz_button_name(SDL::Key.get_key_name(event.sym)), 1)	# 1 is frame_offset: use it on the coming frame

		when SDL::Event2::Quit
			finished!
		end
	end

	#
	# Main Loop
	#
	def run
		start_time = SDL.getTicks
		current_frames_per_second = nil
		frame_number = 1
		timing_start_ms = start_time

		while not finished?
			desired_ms_per_frame = (1000 / @frames_per_second)		# NOTE: desired FPS can change at any time

			frame_start_ms = SDL.getTicks
			timing_start_ms ||= frame_start_ms

			while event = SDL::Event2.poll
				parse_event(event)
			end

			#
			# Render then sleep until time for next frame
			#
			$engine.do_frame((frame_start_ms - start_time) / 1000.0)

			frame_end_ms = SDL.getTicks
			frame_duration_ms = (frame_end_ms - frame_start_ms)

			SDL.GL_swap_buffers		# note trying to not include swap in fps timing
			swap_time_ms = SDL.getTicks - frame_end_ms

			# HACK: recalculate so as not to sleep too much
			frame_end_ms = SDL.getTicks
			frame_duration_ms = (frame_end_ms - frame_start_ms)

			sleep_time_ms = desired_ms_per_frame - frame_duration_ms
			SDL.delay(sleep_time_ms) if sleep_time_ms > 3		# for tiny amounts it doesn't make sense

			frames_per_second = 1000.0 / frame_duration_ms
#			current_frames_per_second ||= frames_per_second
#			current_frames_per_second = (current_frames_per_second + frames_per_second * 9.0) / 10.0		# ...

			if frame_number % TIMING_COUNT == 0
				timing_duration_ms = (frame_end_ms - timing_start_ms)		# we've been timing for many frames
				timing_duration_in_seconds = timing_duration_ms / 1000.0
				seconds_per_frame = timing_duration_in_seconds / TIMING_COUNT
				$env[:current_frames_per_second] = (1.0 / seconds_per_frame).ceil
				timing_start_ms = frame_end_ms
			end

			frame_number += 1

			if $switch_to_project_path
				begin
					$engine.load_from_path($switch_to_project_path)
					$gui.positive_message 'Opened successfully.'
				rescue Exception => e
					e.report('loading project')
					$gui.negative_message 'Open failed.'
				end
				$switch_to_project_path = nil
			end
		end
		SDL.quit

		secs = (SDL.getTicks - start_time) / 1000.0
		puts sprintf('%d frames in %0.1f seconds = %dfps (~%dfps render loop)', $env[:frame_number], secs, $env[:frame_number] / secs, 1.0 / $engine.average_frame_time)
	end

	@@sdl_to_luz_button_names = Hash.new { |hash, key| hash[key] = sprintf('Keyboard / %s', SDL_TO_LUZ_BUTTON_NAMES[key] || key.humanize) }
	def sdl_to_luz_button_name(name)
		@@sdl_to_luz_button_names[name]
	end

	def sdl_to_gui_key(key_name, sdl_event)		# actually decorates the existing String ;P
		key_name.shift = ((sdl_event.mod & SDL::Key::MOD_SHIFT) > 0)
		key_name.control = ((sdl_event.mod & SDL::Key::MOD_CTRL) > 0)
		key_name.alt = ((sdl_event.mod & SDL::Key::MOD_ALT) > 0)
		key_name
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
end
