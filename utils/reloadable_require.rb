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

require 'exception_addons'

module Kernel
	@@source_file_modification_times ||= {}
	@@loading_file_path = nil

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
			e.report
			@@loading_file_path = nil
			return false
		end
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
