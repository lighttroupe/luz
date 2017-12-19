# ImageThumbnailer doesn't thumbnail images (yet?), instead it looks for existing desktop thumbnails
# as per FreeDesktop spec: http://specifications.freedesktop.org/thumbnail-spec/thumbnail-spec-latest.html

require 'digest'

class ImageThumbnailer
	def add(path, &proc)
		file_name = thumbnail_file_name_for_path(path)
		thumbnail_directory_paths.each do |thumbnail_directory_path|
			full_path = File.join(thumbnail_directory_path, file_name)
			if File.exists?(full_path)
				proc.call(full_path)
				return
			end
		end

		p "Thumbnail not found for #{path} (looked in #{thumbnail_directory_paths.join(', ')} with hash #{file_name})"
	end

private

	def thumbnail_directory_paths
		[
			File.join(Dir.home, '.thumbnails/normal'),
			File.join(Dir.home, '.cache/thumbnails/normal'),		# new as of ubuntu 15.04
		]
	end

	def thumbnail_file_name_for_path(path)
		thumbnail_hash_for_path(path)+'.png'
	end

	def thumbnail_hash_for_path(path)
		absolute_path = 'file://'+File.absolute_path(path)		# "absolute canonical URI"		TODO: more proper way to do this?
		Digest::MD5.hexdigest(absolute_path)
	end
end
