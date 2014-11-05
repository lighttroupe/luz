require 'user_object_setting'

class UserObjectSettingImage < UserObjectSetting
	attr_reader :image_name, :width, :height

	def to_yaml_properties
		super + ['@image_name']
	end

	def image_name=(name)
		clear
		@image_name = name
	end

	def after_load
		@width ||= 0
		@height ||= 0
		super
	end

	def summary
		summary_format(@image_name) if @image_name
	end

	def clear
		set(:image_name, nil)
		@image_list = nil
		@width = 0
		@height = 0
	end

	def color_at(x,y)
		@default_color ||= Color.new
		load_images if @image_list.nil?
		return @default_color unless @image_list

		# we only support color picking from the first
		@image_list[0].color_at(x, y)
	end

	def using
		using_index(0) {
			yield
		}
	end

	def using_progress(progress)
		load_images if @image_list.nil?
		return yield unless @image_list

		index = @image_list.size.choose_index_by_fuzzy(progress)

		using_index(index) {
			yield
		}
	end

	def using_index(index)
		# TODO: load via the engine, so we don't load the same file path twice
		load_images if @image_list.nil?
		return yield unless @image_list

		@image_list[index % @image_list.size].using {
			# TODO: add texture options
			yield
		}
	end

	def one
		load_images if @image_list.nil?
		return nil unless @image_list
		@image_list[0]		# for now
	end

	def load_images
		# NOTE: assumes @image_list is nil
		if @image_name
			@image_list = $engine.load_images(@image_name)

			if @image_list
				@width = @image_list[0].width
				@height = @image_list[0].height
			end
		end
		@image_list
	end

	# Somewhat of a hack to save screenshots live to a theme
	def set_pixels(pixels, width, height)
		@image_list ||= []
		@image_list[0] ||= Image.new
		@image_list[0].from_rgb8(pixels, @width=width, @height=height)
	end
end
