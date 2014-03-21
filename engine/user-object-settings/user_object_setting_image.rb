 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

require 'user_object_setting'

class UserObjectSettingImage < UserObjectSetting
	def to_yaml_properties
		['@image_name'] + super
	end

	attr_reader :image_name, :width, :height

	def image_name=(name)
		clear
		@image_name = name
	end

	def after_load
		@width ||= 0
		@height ||= 0
		super
	end

	def files_used
		[@image_name] + super
	end

	def summary
		summary_format(@image_name) if @image_name
	end

	DEFAULT_BUTTON_TEXT = 'Choose'
	IMAGE_MIME_TYPE_FILTER = 'image/*'

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
