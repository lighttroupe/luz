require 'pango'

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

	boolean_accessor :drawn

	def symbol_to_pango_align(sym)
		{:left => Pango::ALIGN_LEFT, :center => Pango::ALIGN_CENTER, :right => Pango::ALIGN_RIGHT}[sym] || Pango::ALIGN_LEFT
	end

	def render_text(font, text)
		@canvas ||= CairoCanvas.new(1024, 1024)
		@image ||= Image.new

		unless drawn?
			@canvas.using { |context|
				context.save
					# clear
					context.set_source_rgba(0.0, 0.0, 0.0, 0.0)		# NOTE: alpha 0.0
					context.set_operator(:source)
					context.paint

					# Default Cairo coordinates has 0,0 in the upper left, with 1 unit translating to 1 pixel
					# Scale it so that the whole canvas goes 0.0 -> 1.0 horizontally and 0.0 -> 1.0 vertically
					context.scale(@canvas.width, @canvas.height)

					# Move cursor to center
					context.translate(0.5, 0.5)

					context.set_source_rgba(1,1,1,1)
					context.set_antialias(Cairo::ANTIALIAS_GRAY)		# or DEFAULT or GRAY or SUBPIXEL or NONE

					font_description = font
					weight = Cairo::FONT_WEIGHT_NORMAL
					if font =~ / Bold/
						font = font.gsub(' Bold', '')
						weight = Pango::WEIGHT_BOLD
					end

					slant = Cairo::FONT_SLANT_NORMAL
					if font =~ / Italic/
						font = font.gsub(' Italic', '')
						style = Pango::STYLE_ITALIC
					end

					layout = context.create_pango_layout
					text_fixed = text.gsub("\n", " \n")
					layout.text = text_fixed

					layout.alignment = symbol_to_pango_align(font_alignment)

					# Wrapping
					#layout.width = @canvas.width

					font_description = Pango::FontDescription.new(font_description)
					font_description.absolute_size = font_size * Pango::SCALE

					layout.font_description = font_description

					layout.spacing = line_spacing * Pango::SCALE # line spacing

					# NOTE: these are in 0.0-1.0 units
					layout_width, layout_height = layout.pixel_size

					context.move_to(border_left.scale(-RADIUS, 0.0), border_top.scale(-RADIUS, 0.0))

	#				context.scale(1, @canvas.height / layout_height)

					context.show_pango_layout(layout)

=begin
				context.select_font_face(font, slant, weight)
				context.set_font_size(0.1)

				extents = context.text_extents(text)

				context.move_to(-0.5 - extents.x_bearing, -0.4)
				context.show_text(text)
=end
				context.restore
			}
			@image.from_bgra8(@canvas.string_data, @canvas.width, @canvas.height)
			drawn!
		end

		@image
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
end
