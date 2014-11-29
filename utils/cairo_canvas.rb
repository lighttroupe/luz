require 'cairo_context'

class CairoCanvas
	attr_reader :width, :height, :string_data, :context

	def initialize(width, height)
		@width, @height = width, height

		@string_data = ("\0" * (@width * @height * 4))		# TODO: ensure this is right for RUBY1.9, RUBY2.0 etc.
		@cairo_surface = Cairo::ImageSurface.new(@string_data, Cairo::FORMAT_ARGB32, @width, @height, stride = (@width * 4))

		@context = Cairo::Context.new(@cairo_surface)
		@context.paint
	end

	pipe :track_dirty_rects=, :context
	pipe :dirty_rects, :context
	pipe :dirty_rects_clear, :context
	pipe :entire_canvas_dirty?, :context
	pipe :entire_canvas_dirty=, :context

	def using
		yield @context
	end
end
