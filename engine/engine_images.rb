module EngineImages
	#
	# Image loading and caching
	#
	def load_images(path)
		# all images paths are relative and with/below project file
		file_path = File.join(@project.file_path, path)

		# Note: cache using the full path name, so that two projects with similar relative paths won't get confused
		@images_cache ||= {}
		return @images_cache[file_path] if @images_cache[file_path]

		case File.extname(file_path).downcase
		when '.png', '.jpg', '.jpeg', '.bmp'
			return (@images_cache[file_path] = [Image.new.from_image_file_path(file_path)])
		when '.gif'
			begin
				list = Magick::ImageList.new(file_path).coalesce
				image_list = []
				list.each { |rmagick_image| image_list << Image.new.load_from_rmagick_image(rmagick_image) }
				return (@images_cache[file_path] = image_list)
			rescue
				return false
			end
		else
			puts "unhandled image file type for #{file_path}"
			return false
		end
	end
end
