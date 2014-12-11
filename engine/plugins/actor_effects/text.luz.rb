multi_require 'pango', 'cairo_font'

class ActorEffectText < ActorEffect
	title				"Text"
	description "Apply text to actor."

	categories :color

	setting 'font', :font, :on_change => :not_drawn!
	setting 'text', :string, :multiline => true, :on_change => :not_drawn!

	setting 'font_size', :float, :default => 0.1..1.0, :range => 0.0..1.0, :simple => true, :on_change => :not_drawn!

	ALIGNMENT_OPTIONS = [[:left, 'Left'], [:center, 'Center'], [:right, 'Right']]
	setting 'font_alignment', :select, :options => ALIGNMENT_OPTIONS, :on_change => :not_drawn!

	setting 'line_spacing', :float, :default => 0.0..1.0, :range => -1.0..1.0, :simple => true, :on_change => :not_drawn!

	setting 'border_left', :float, :default => 0.0..1.0, :range => -1000.0..1000.0, :on_change => :not_drawn!
	setting 'border_top', :float, :default => 0.0..1.0, :range => -1000.0..1000.0, :on_change => :not_drawn!

	setting 'lines', :integer, :default => 1..10, :range => 1..100, :on_change => :not_drawn!

	boolean_accessor :drawn

	def width
		20
	end

	def render
		image = render_text(font, text)
		return yield unless image

		image.using {
			yield
		}
	end

	def deep_clone(*args)
		@canvas = nil
		@image = nil
		not_drawn!
		super(*args)
	end

	#
	# TODO: move elsewhere
	#
	def render_text(font, text)
		@cairo_font ||= CairoFont.new
		unless drawn?
			@image = @cairo_font.render_to_image(text, font, width, lines, font_alignment)
			drawn!
		end
		@image
	end
end
