#
# Image is a wrapper for an OpenGL Texture, with loading and sampling support.
#
RMAGICK_BYPASS_VERSION_TEST = true			# work around bug in rmagick-ruby for ubuntu 10.04
require 'RMagick'
require 'drawing'

class Image
	include Drawing

	attr_reader :width, :height

	def initialize(options={})
		@opengl_texture_id = GL.GenTexture
		set_texture_options(options)
	end

	def set_texture_options(options)
		using {
			# TODO: make these based on instance variables and part of Drawing
			GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, options[:repeat] ? GL::REPEAT : GL::CLAMP) #REPEAT)			# REPEAT mode adds noise to the transparent edge of a texture opposite an opaque edge
			GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, options[:repeat] ? GL::REPEAT : GL::CLAMP) #REPEAT)

			GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, options[:no_smoothing] ? GL::NEAREST : GL::LINEAR)
			GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, options[:no_smoothing] ? GL::NEAREST : GL::LINEAR)

			#GL.TexParameter(GL::TEXTURE_2D, GL::GENERATE_MIPMAP, GL::TRUE)
		}
		self
	end

	#
	# primary API
	#
	def using
		call_load_proc_if_needed!
		with_texture(@opengl_texture_id) {
			yield
		}
	end

	def texture_id
		call_load_proc_if_needed!
		@opengl_texture_id
	end

	#
	# Loading of pixel data		(NOTE: this method saves rgba data, so it can be reloaded if necessary)
	#
	def from_image_file_path(file_path)
		begin
			image = Magick::Image.read(file_path).first
			load_from_rmagick_image(image)
		rescue #Magick::ImageMagickError
			puts "#{file_path} load failed"
			self
		end
	end

	def load_from_rmagick_image(image)
		$support_non_power_of_two = Gl.is_available?("ARB_texture_non_power_of_two") if $support_non_power_of_two.nil?

		unless $support_non_power_of_two
			# Ensure powers of two textures
			new_width = round_to_power_of_two(image.columns)
			new_height = round_to_power_of_two(image.rows)
			image.resize!(new_width, new_height) if (new_width != image.columns or new_height != image.rows)
		end

		@rgba_data, @width, @height = image.to_blob { |i| i.format = 'RGBA' ; i.depth = 8 }, image.columns, image.rows
		#from_rgba8(@rgba_data, @width, @height)
		@load_proc = Proc.new { from_rgba8(@rgba_data, @width, @height) }
		self
	end

	def call_load_proc_if_needed!
		if proc=@load_proc
			@load_proc = nil		# (important to clear it before calling, depending on what the callback does)
			proc.call
		end
	end

	#
	# Copying pixel data to OpenGL (NOTE: these methods don't *save* the data in Ruby)
	#
	def from_rgba8(data, width, height)
		using {
			GL.TexImage2D(GL::TEXTURE_2D, mipmap=0, GL::RGBA, width, height, border=0, GL::RGBA, GL::UNSIGNED_BYTE, data)
			yield if block_given?
		}
		self
	end

	def from_rgb8(data, width, height)
		using {
			GL.TexImage2D(GL::TEXTURE_2D, mipmap=0, GL::RGBA, width, height, border=0, GL::RGB, GL::UNSIGNED_BYTE, data)
			yield if block_given?
		}
		self
	end

	def from_bgra8(data, width, height)
		using {
			GL.TexImage2D(GL::TEXTURE_2D, mipmap=0, GL::RGBA, width, height, border=0, GL::BGRA, GL::UNSIGNED_BYTE, data)
			yield if block_given?
		}
		self
	end

	def from_bgra8_partial(data, data_width, data_height, x, y, width, height)
		using {
			GL.PixelStore(GL::UNPACK_SKIP_ROWS, y)							# this lets us choose correct source pixels
			GL.PixelStore(GL::UNPACK_SKIP_PIXELS, x)
			GL.PixelStore(GL::UNPACK_ROW_LENGTH, data_width)		# this sets the 'stride', skipping unwanted pixels in each row

			# copy to specified destination pixels
			GL.TexSubImage2D(GL::TEXTURE_2D, mipmap=0, x,y,width,height, GL::BGRA, GL::UNSIGNED_BYTE, data)

			# reset
			GL.PixelStore(GL::UNPACK_ROW_LENGTH, 0)
			GL.PixelStore(GL::UNPACK_SKIP_ROWS, 0)
			GL.PixelStore(GL::UNPACK_SKIP_PIXELS, 0)
		}
		self
	end

	#
	# Sampling
	#
	def rgba_at(x_fuzzy, y_fuzzy)
		return [0.0,0.0,0.0,0.0] unless @rgba_data
		x_index, y_index = @width.choose_index_by_fuzzy(x_fuzzy), @height.choose_index_by_fuzzy(y_fuzzy)
		rgba_pixel = @rgba_data[((y_index * @width) + x_index) * 4, 4].unpack('CCCC')
		rgba_pixel.collect { |component| component / 255.0 }
	end

	def color_at(x_fuzzy, y_fuzzy)
		return Color.new unless @rgba_data
		x_index, y_index = @width.choose_index_by_fuzzy(x_fuzzy), @height.choose_index_by_fuzzy(y_fuzzy)
		rgba_pixel = @rgba_data[((y_index * @width) + x_index) * 4, 4].unpack('CCCC')
		Color.new_from_rgba_bytes(rgba_pixel)
	end

private

	def round_to_power_of_two(positive_integer)
		case positive_integer
		when 0..2 then 2
		when 3..4 then 4
		when 5..8 then 8
		when 9..16 then 16
		when 17..32 then 32
		when 33..64 then 64
		when 65..128 then 128
		when 129..256 then 256
		when 257..512 then 512
		when 513..1024 then 1024
		when 1025..2048 then 2048
		when 2049..4096 then 4096
		when 4097..8192 then 8192
		else
			raise "this image is far too big"
		end
	end
end
