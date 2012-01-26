begin
require 'cairo'

class Cairo::Context
	boolean_accessor :track_dirty_rects
	boolean_accessor :entire_canvas_dirty
	attr_reader :dirty_rects

	def add_dirty_rect(rect)
		@dirty_rects ||= []
		@dirty_rects << rect
	end

	def dirty_rects_clear
		r = @dirty_rects
		@dirty_rects = nil
		r || []
	end

	alias :fill_without_dirty_rects :fill
	def fill
		add_dirty_rect(fill_extents) if track_dirty_rects?
		fill_without_dirty_rects
	end

	alias :fill_preserve_without_dirty_rects :fill_preserve
	def fill_preserve
		add_dirty_rect(fill_extents) if track_dirty_rects?
		fill_without_dirty_rects(true)
	end

	alias :stroke_without_dirty_rects :stroke
	def stroke
		add_dirty_rect(stroke_extents) if track_dirty_rects?
		stroke_without_dirty_rects
	end

	alias :stroke_preserve_without_dirty_rects :stroke_preserve
	def stroke_preserve
		add_dirty_rect(stroke_extents) if track_dirty_rects?
		stroke_without_dirty_rects(true)
	end

	alias :paint_without_dirty_rects :paint
	def paint(amt=1.0)
		set_entire_canvas_dirty(true) if track_dirty_rects?
		paint_without_dirty_rects(amt)
	end
end
rescue LoadError
end
