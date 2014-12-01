#
# CairoFont uses Cairo and Pango to render text onto an Image (OpenGL surface)
#
class CairoFont
	#easy_accessor :font, :string

	def render_to_image(string, font, width_in_characters)
		@canvas ||= CairoCanvas.new(64*5, 64)		# TODO: appropriate size
		@image ||= Image.new
		render(string, font, size=1.0, :center, width_in_characters)
		@image
	end

private

	def render(string, font, font_size, alignment=:center, width_in_characters)
		#line_spacing = 1.0		# TODO ?
		border_left = 0.0
		border_top = 0.0

		@canvas.using { |context|
			context.save
				clear_canvas(context)

				unless string.blank?
					# Color
					context.set_source_rgba(1,1,1,1)
					context.set_antialias(Cairo::ANTIALIAS_GRAY)		# or DEFAULT or GRAY or SUBPIXEL or NONE

					# Default Cairo coordinates has 0,0 in the upper left, with 1 unit translating to 1 pixel
					# Scale it so that the whole canvas goes 0.0 -> 1.0 horizontally and 0.0 -> 1.0 vertically
					#context.scale(@canvas.width, @canvas.height)

					# "layout" - a Pango plan for rendering
					layout = context.create_pango_layout
					layout.text = string.gsub("\n", " \n")		# TODO: document why ?!
					layout.alignment = symbol_to_pango_align(alignment)
					#layout.width = @canvas.width					# TODO: wrapping

					# build Pango font description
					font_description = Pango::FontDescription.new(font)
					font_description.absolute_size = font_size * Pango::SCALE * @canvas.height
					layout.font_description = font_description

					# TODO: line spacing
					# layout.spacing = line_spacing * Pango::SCALE

					# TODO: padding
					#context.move_to(border_left.scale(-0.5, 0.0), border_top.scale(-0.5, 0.0))

					#puts string
					if width_in_characters == :stretch
						# scale to fill horizontally
						layout_width, layout_height = layout.pixel_size
						#puts "size       == width:#{layout_width}, height:#{layout_height}"
						context.scale(@canvas.width / layout_width.to_f, 0.75)
					else
						context.scale(1.0 / 3, 0.75)
					end
					#puts "layout_width = #{layout_width}, layout_height = #{layout_height}"
					#context.scale(1, @canvas.height / layout_height)
					context.show_pango_layout(layout)
				end
			context.restore
		}
		@image.from_bgra8(@canvas.string_data, @canvas.width, @canvas.height)
	end

	def clear_canvas(context)
		context.set_source_rgba(0.0, 0.0, 0.0, 0.0)		# NOTE: alpha 0.0
		context.set_operator(:source)
		context.paint
	end

	def symbol_to_pango_align(sym)
		{:left => Pango::ALIGN_LEFT, :center => Pango::ALIGN_CENTER, :right => Pango::ALIGN_RIGHT}[sym] || Pango::ALIGN_LEFT
	end
end

#font_description = font
#weight = Cairo::FONT_WEIGHT_NORMAL
#if font =~ / Bold/
	#font = font.gsub(' Bold', '')
	#weight = Pango::WEIGHT_BOLD
#end

#slant = Cairo::FONT_SLANT_NORMAL
#if font =~ / Italic/
	#font = font.gsub(' Italic', '')
	#style = Pango::STYLE_ITALIC
#end
