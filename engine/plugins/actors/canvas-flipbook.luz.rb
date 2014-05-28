require 'actor_canvas'

class ActorCanvasFlipbook < ActorCanvas
	title				"Canvas Flipbook"
	description "Similar to a normal Canvas, but adds multiple pages and the ability to switch between them.\n\nAlso supports onion skinning by showing the previous page in the background with chosen color and alpha.\n\nEffects operate only on the current page."

	setting 'forward', :event
	setting 'backward', :event
	setting 'pages', :integer, :range => 1..100, :default => 2..6
	setting 'previous_color', :color, :default => [1.0, 1.0, 1.0, 0.2]

	def deep_clone(*args)
		@cairo_canvases, @previous_image, @previous_page_index, @last_copy_to_texture_frame_number = nil, nil, nil, nil		# can't clone these
		super(*args)
	end

	def cairo_canvas
		@cairo_canvases ||= []
		@cairo_canvases[page_index] ||= new_cairo_canvas
	end

	def render
		@previous_image ||= new_image

		# Have we switched canvases?
		if @previous_page_index != page_index
			#puts 'swapping'
			# Swap (this way the current image moves to 'previous' without extra copy)
			@previous_image, @image = image, @previous_image

			# Ensure full memory->OpenGL copy
			@last_copy_to_texture_frame_number = nil

			# Make note
			@previous_page_index = page_index
		end

		# Draw other image with fade
		with_color(previous_color) {
			@previous_image.using { fullscreen_rectangle }
		} unless previous_color.alpha == 0.0

		# Draw canvas to image, etc.
		super
	end

	def page_index
		(forward.count - backward.count) % pages
	end
end
