class Dir
	def each_with_extensions(extensions)		# accepts array of extensions eg. ['png', 'gif', 'jpg', 'jpeg']
		each { |filename| yield File.join(path, filename) if extensions.nil? || extensions.include?(File.extname(filename).sub(/^\./,'')) }
	end

	def each_matching(pattern)	# accepts patterns like '*.png'
		each { |filename| yield File.join(path, filename) if File.fnmatch(pattern, filename) }
	end

	def each_matching_recursive(pattern)	# accepts patterns like '*.png'
		each { |filename|
			unless filename == '..' or filename == '.'
				filepath = File.join(path, filename)

				if File.directory?(filepath)
					# When we find directories, recurse
					Dir.new(filepath).each_matching_recursive(pattern) { |filepath| yield filepath }
				elsif File.fnmatch(pattern, filename)
					# Send matching file names back to parent
					yield filepath
				end
			end
		}
	end
end
