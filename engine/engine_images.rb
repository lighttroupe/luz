module EngineImages
	#
	# Image loading, caching, and reloading upon changes (using inotify)
	#
	def load_images(path)
		# all images paths are relative and with/below project file
		file_path = File.join(@project.file_path, path)

		# Note: cache using the full path name, so that two projects with similar relative paths won't get confused
		@images_cache ||= {}
		return @images_cache[file_path] if @images_cache[file_path]

		unless File.exists? file_path
			puts "Engine#load_images: file doesn't exist \"#{file_path}\"" 
			return (@images_cache[file_path] ||= [Image.new])
		end

		ret = nil
		with_watch(file_path) {
			@images_cache[file_path] ||= []		# this is what's returned, so this should not be replaced with a new []

			case File.extname(file_path).downcase
			when '.png', '.jpg', '.jpeg', '.bmp'
				@images_cache[file_path][0] ||= Image.new
				timer("load #{path}", :if_over => 0.1) {
					@images_cache[file_path][0].from_image_file_path(file_path)
				}
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
		return ret
	end
 
	if optional_require 'rb-inotify'
		$notifier ||= INotify::Notifier.new

		def with_watch(file_path)
			# Load file
			if yield

				# Add a watch, and when it fires, yield again
				$notifier.watch(file_path, :close_write) {
					puts "Reloading #{file_path} ..."
					yield
				}

				$notifier_io = [$notifier.to_io]
				$engine.on_frame_end { $notifier.process if IO.select($notifier_io, nil, nil, 0) } unless $notifier_callback_set
				$notifier_callback_set = true
			end
		end
	else
		def with_watch(file_path)
			yield
		end
	end
end
