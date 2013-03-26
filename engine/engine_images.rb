module EngineImages
	#
	# Image loading, caching, and reloading upon changes (using inotify)
	#
	def image_directories
		[
			@project.file_path,
			'gui-ruby'
		].compact
	end

	def load_images(path)
		path = path.sub(@project.file_path, '') if @project.file_path && path.index(@project.file_path) == 0

		# supports absolute paths, or relative paths from one of the registered image directories
		file_path = ([path] + image_directories.map { |dir| File.join(dir, path) }).find { |p|
			File.exists?(p)
		}

		# Note: cache using the full path name, so that two projects with similar relative paths won't get confused
		@images_cache ||= {}
		return @images_cache[file_path] if @images_cache[file_path]

		unless file_path && File.exists?(file_path)
			puts "Engine#load_images: file doesn't exist \"#{file_path}\"" 
			return (@images_cache[file_path] ||= [Image.new])
		end

		ret = nil
		with_watch(file_path) {
			@images_cache[file_path] ||= []		# DO NOT replace with [] as that would invalidate external object references

			timer("load #{path}", :if_over => 0.1) {
				case File.extname(file_path).downcase
				when '.png', '.jpg', '.jpeg', '.bmp'
					@images_cache[file_path][0] ||= Image.new
					@images_cache[file_path][0].from_image_file_path(file_path)
					ret = @images_cache[file_path]
				when '.gif'
					begin
						list = Magick::ImageList.new(file_path).coalesce
						image_list = @images_cache[file_path]
						list.each_with_index { |rmagick_image, index| image_list[index] ||= Image.new ; image_list[index].load_from_rmagick_image(rmagick_image) }
						ret = image_list
					rescue
						ret = false
					end
				else
					puts "unhandled image file type for #{file_path}"
					ret = false
				end
			}
			true		# tell with_watch that we were successful
		}
		return ret
	end

	# Helper when we know it's just one image
	def load_image(path)
		if (images=load_images(path))
			images.first
		end
	end
end
