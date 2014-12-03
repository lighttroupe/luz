#
# CairoFont uses Cairo and Pango to render text onto an Image (OpenGL surface)
#
class CairoFont
	#easy_accessor :font, :string

	def render_to_image(string, font, width_in_characters, text_align)
		@canvas ||= CairoCanvas.new(512, 256)		# TODO: appropriate size
		@image ||= Image.new
		render(string, font, size=1.0, width_in_characters, text_align)
		@image
	end

	def self.renderable?(character)
		true		# TODO: limit?
	end

private

	def render(string, font, font_size, width_in_characters, text_align)
		#line_spacing = 1.0		# TODO ?
		border_left = 0.0
		border_top = 0.0
		lines = 1

		@canvas.using { |context|
			context.save
				clear_canvas(context)

				unless string.blank?
					# color
					context.set_source_rgba(1,1,1,1)
					context.set_antialias(Cairo::ANTIALIAS_GRAY)		# or DEFAULT or GRAY or SUBPIXEL or NONE

					# "layout" - a Pango plan for rendering
					layout = context.create_pango_layout
					#layout.alignment = symbol_to_pango_align(alignment)
					#layout.width = @canvas.width					# TODO: wrapping
					#layout.spacing = line_spacing * Pango::SCALE					# TODO: line spacing

					# build Pango font description
					font_description = Pango::FontDescription.new(font)

					# sets height to full canvas height
					font_description.absolute_size = @canvas.height * Pango::SCALE / lines		# * font_size
					layout.font_description = font_description

					# measure one "em"  https://en.wikipedia.org/wiki/Em_%28typography%29
					layout.text = "M"
					em_width, em_height = layout.pixel_size

					layout.text = string		#.gsub("\n", " \n")		# TODO: document why ?!

					case width_in_characters
					when :fill
						# scale to fill horizontally
						layout_width, layout_height = layout.pixel_size
						context.scale(@canvas.width / layout_width.to_f, 0.85)
					else
						logical_width_in_pixels = width_in_characters * em_width
						actual_width_in_pixels = @canvas.width

						#puts "em_width => #{em_width}, em_height => #{em_height}"
						#puts "logical_width_in_pixels=#{logical_width_in_pixels}, actual_width_in_pixels=#{actual_width_in_pixels}"

						horizontal_scale = actual_width_in_pixels.to_f / logical_width_in_pixels.to_f
						vertical_scale = 0.85

						#puts "width_in_characters=#{width_in_characters}, horizontal_scale=#{horizontal_scale}"

						case text_align
						when :left, nil		# default
							# font is 1 tall, width is approx how many chars we can show
							context.scale(horizontal_scale, vertical_scale)
						when :center
							# Center layout assumes the string is smaller than the container
							layout_width, layout_height = layout.pixel_size
							free_space = (@canvas.width.to_f - (layout_width.to_f * horizontal_scale))		# NOTE: using final, post-scaled text width
							context.move_to((free_space / 2.0), 0.0)		# if free_space > 0.0
							context.scale(horizontal_scale, vertical_scale)
						when :right
							layout_width, layout_height = layout.pixel_size
							free_space = (@canvas.width.to_f - (layout_width.to_f * horizontal_scale))		# NOTE: using final, post-scaled text width
							context.move_to(free_space, 0.0)
							context.scale(horizontal_scale, vertical_scale)
						else
							raise "text_align = #{text_align}"
						end
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
