require 'cairo_context'

class CairoCanvas
	attr_reader :width, :height, :string_data

	def initialize(width, height)
		@width, @height = width, height

		@string_data = ("\0" * (@width * @height * 4))		# TODO: ensure this is right for RUBY1.9, RUBY2.0 etc.
		@cairo_surface = Cairo::ImageSurface.new(@string_data, Cairo::FORMAT_ARGB32, @width, @height, stride = (@width * 4))

		@cr = Cairo::Context.new(@cairo_surface)
		@cr.paint
	end

	pipe :track_dirty_rects=, :cr
	pipe :dirty_rects, :cr
	pipe :dirty_rects_clear, :cr
	pipe :entire_canvas_dirty?, :cr
	pipe :entire_canvas_dirty=, :cr

	def using
		yield @cr
	end
end
