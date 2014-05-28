class FontFactory
	def character_image(font, character)
		# a canvas to draw onto, before copying to OpenGL
		@canvas ||= CairoCanvas.new(256,256)

		@images_for_characters ||= {}		# keyed first by font...
		@images_for_characters[font] ||= Hash.new { |hash, key|
			hash[key] = generate_character_image(font, key)	# ..then by character
		}

		@images_for_characters[font][character]
	end

	def generate_character_image(font, character)
		puts "generating #{font} #{character}"
		image = Image.new

		@canvas.using { |context|
			context.save
				# clear
				context.set_source_rgba(0.0, 0.0, 0.0, 0.0)		# NOTE: alpha 0.0
				context.set_operator(:source)
				context.paint

				# Default Cairo coordinates has 0,0 in the upper left, with 1 unit translating to 1 pixel
				# Scale it so that the whole canvas goes 0.0 -> 1.0 horizontally and 0.0 -> 1.0 vertically
				context.scale(@canvas.width, @canvas.height)		# NOTE: height is multiplied by -1 to flip the canvas vertically, so bigger numbers go up (cartessian plane)

				# Move cursor to center
				context.translate(0.5, 0.5)

				context.set_source_rgba(1,1,1,1)
				context.set_antialias(Cairo::ANTIALIAS_GRAY)		# or DEFAULT or GRAY or SUBPIXEL or NONE

				weight = Cairo::FONT_WEIGHT_NORMAL
				if font =~ / Bold/
					font = font.gsub(' Bold', '')
					weight = Cairo::FONT_WEIGHT_BOLD
				end

				slant = Cairo::FONT_SLANT_NORMAL
				if font =~ / Italic/
					font = font.gsub(' Italic', '')
					slant = Cairo::FONT_SLANT_ITALIC
				end

				context.select_font_face(font, slant, weight)
				context.set_font_size(0.9)

				extents = context.text_extents(character)

				context.move_to(-0.5 - extents.x_bearing + ((1.0 - extents.width)/2.0), 0.25)
				context.show_text(character)
			context.restore
		}

		image.from_bgra8(@canvas.string_data, @canvas.width, @canvas.height)
		image
	end
end

$font_factory ||= FontFactory.new

class ActorEffectTextChildren < ActorEffect
	title				"Text Children"
	description "Apply text to children, one letter per child."

	categories :color, :child_consumer

	setting :font, :font
	setting :text, :string

	def render
		character = text[child_index]
		return unless character

		image = $font_factory.character_image(font, character.chr)
		return unless image

		image.using {
			yield
		}
	end
end
