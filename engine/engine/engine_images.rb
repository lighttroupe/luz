#
# Image loading, caching, and reloading upon changes (using inotify)
#
multi_require 'image_thumbnailer'

module EngineImages
	SUPPORTED_IMAGE_EXTENSIONS = ['png','jpg','jpeg','bmp','gif']

	#
	# API
	#
	def load_image(path)
		if (images=load_images(path))
			images.first
		end
	end

	def load_image_thumbnail(path, &proc)
		thumbnailer.add(path) { |thumbnail_path|
			image = load_image(thumbnail_path)
			proc.call(image) if image
		}
	end

	def load_images(relative_path)
		@images_cache ||= {}

		relative_path = relative_path.without_prefix(@project.file_path) if @project.file_path

		file_path = find_file_by_relative_path(relative_path)

		# Note: cache using the full path name, so that two projects with similar relative paths won't get confused
		return @images_cache[file_path] if @images_cache[file_path]

		unless file_path && File.exists?(file_path)
			puts "Engine#load_images: file doesn't exist \"#{file_path}\"" 
			return (@images_cache[file_path] ||= [Image.new])
		end

		return_value = nil
		with_watch(file_path) {
			@images_cache[file_path] ||= []		# DO NOT replace with [] as that would invalidate external object references

			timer("load #{relative_path}", :if_over => 0.1) {
				case File.extname(file_path).downcase
				when '.png', '.jpg', '.jpeg', '.bmp'
					@images_cache[file_path][0] ||= Image.new
					@images_cache[file_path][0].from_image_file_path(file_path)
					return_value = @images_cache[file_path]
				when '.gif'
					begin
						list = Magick::ImageList.new(file_path).coalesce
						image_list = @images_cache[file_path]
						list.each_with_index { |rmagick_image, index| image_list[index] ||= Image.new ; image_list[index].load_from_rmagick_image(rmagick_image) }
						return_value = image_list
					rescue
						return_value = false
					end
				else
					puts "unhandled image file type for #{file_path}"
					return_value = false
				end
			}
			true		# tell with_watch that we were successful
		}
		return_value
	end

private

	# given an absolute or relative path, find an existing file in one of the registered image directories
	def find_file_by_relative_path(relative_path)
		([relative_path] + image_directories.map { |dir| File.join(dir, relative_path) }).find { |p|
			File.exists?(p)
		}
	end

	def image_directories
		[@project.file_path, 'gui'].compact
	end

	def thumbnailer
		@thumbnailer ||= ImageThumbnailer.new
	end
end
