require 'addons/exception'
require 'addons/dir'

module Kernel
	@@source_file_modification_times ||= {}
	@@loading_file_path = nil

	def optional_require(file)
		begin
			require file
			return true
		rescue LoadError
			return false
		end
	end

	# a new 'require' supporting multiple files
	#alias_method :single_require, :require
	def multi_require(*list)
		[*list].each { |file|
			if require(file)
				# Grab latest file name (which now includes the .rb) from $LOADED_FEATURES (list of all require'd files)
				ext = File.extname($LOADED_FEATURES.last)

				# Add on extension unless it already has it (seems to happen with .so files)
				file += ext unless file[-ext.length, ext.length] == ext

				# Find the full file path that was loaded by searching the path the way Ruby does
				path = $:.find { |path| File.exist?(File.join(path, file)) }
				next unless path		# seems to fail for some system libs (won't need reloading anyway)

				filepath = File.join(path, file)

				# Add to list
				@@source_file_modification_times[filepath] = File.new(filepath).mtime
			end
		}
	end

	def reload_if_newer(filepath)
		file = File.new(filepath) rescue nil
		return false unless file		# no longer exists?

		mtime = file.mtime
		file.close

		# Do we already have the current version?
		return false if mtime == @@source_file_modification_times[filepath]
		@@source_file_modification_times[filepath] = mtime

		begin
			@@loading_file_path = filepath
			#puts "Reloading - #{@@loading_file_path} ..."
			load filepath
			@@loading_file_path = nil
			return true
		rescue Exception => e
			$gui.positive_message "File Reload Failed" if $gui
			puts "File Reload Failed - #{@@loading_file_path}:"
			e.report
			@@loading_file_path = nil
			return false
		end
	end

	def load_directory(path, filter_pattern='*rb')
		count = 0
		paths = []		# collect and then sort to make load order consistent
		Dir.new(path).each_matching_recursive(filter_pattern) { |filepath| paths << filepath }
		paths.sort.each { |filepath| count += 1 if reload_if_newer(filepath) }
		return count
	end

	def reload_modified_source_files
		count = 0
		@@source_file_modification_times.each_key { |filepath| count += 1 if reload_if_newer(filepath) }
		count
	end

	def self.loading_file_path
		@@loading_file_path
	end
end
