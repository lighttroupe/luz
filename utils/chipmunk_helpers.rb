#
# Chipmunk-specific safe type conversion
#
def as_float(string_value, default = 0.0)
	return default unless string_value
	return CP::INFINITY if string_value == 'infinite'
	return string_value.to_f
end

def as_integer(string_value, default = 0)
	return default unless string_value
	return string_value.to_i
end

DRAW_METHOD_LOOKUP = {'normal' => :average, 'multiply' => :multiply, 'screen' => :brighten, 'darken' => :min, 'lighten' => :max, 'brighten' => :brighten, 'invert' => :invert}
def as_draw_method(string)
	DRAW_METHOD_LOOKUP[string]
end

def make_collision_type_symbol(text)
	text.strip.downcase.gsub(' ', '_').gsub('-', '_').to_sym
end

#
# Image helper
#
def with_optional_image(options)
	image = options[:image]
	return yield unless image
	image.using {
		#
		# Map Feature: image-repeat-x and image-repeat-y support
		#
		if (image_repeat_x=options[:image_repeat_x]) or (image_repeat_y=options[:image_repeat_y])
			# Is this fast enough?  Does it work well enough with display lists?
			GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT) if image_repeat_x
			GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT) if image_repeat_y

			with_texture_scale(as_float(image_repeat_x, 1.0), as_float(image_repeat_y, 1.0)) {
				yield
			}
		else
			yield
		end
	}
end

#
# Addons to existing classes
#
class Array
	def clean_vertex_list
		last = nil
		map! { |v|
			if last and v == last
				nil
			else
				last=v
			end
		}
		compact!
		pop if first == last
		self
	end
end

# returns true if killed
def damage_drawables(drawables, damage_amount, damage_type=nil)
	return false unless drawables
	killed = false
	drawables.each { |drawable| killed = true if drawable.damage!(damage_amount, damage_type) }
	return killed
end
