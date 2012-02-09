 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
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

require 'yaml', 'project_effect'

require 'zaml'

# For File.mv
begin
	require 'ftools'		# ruby 1.8
rescue LoadError
	require 'fileutils'	# ruby 1.9
end

require 'callbacks'

class Project
	include Callbacks

	callback :changed

	FILE_VERSION = 1
	FILE_EXTENSION = 'luz'
	FILE_EXTENSION_WITH_DOT = '.luz'
	FILE_PATTERN = '*.' + FILE_EXTENSION

	OBJECT_SYMBOLS = [:actors, :directors, :themes, :curves, :variables, :events, :effects]
	OBJECT_SYMBOL_TO_CLASS = {:actors => Actor, :directors => Director, :themes => Theme, :curves => Curve, :variables => Variable, :events => Event, :effects => ProjectEffect}
	CLASS_TO_OBJECT_SYMBOL = {Actor => :actors, Director => :directors, Theme => :themes, Curve => :curves, Variable => :variables, Event => :events, ProjectEffect => :effects}

	attr_accessor *OBJECT_SYMBOLS

	OBJECT_SYMBOLS.each { |name|
		define_method(name) {
			instance_variable_get('@' + name.to_s)
		}

		define_method(name.to_s + '=') { |value|
			instance_variable_set('@' + name.to_s, value)
			changed!
		}
	}

	attr_reader :change_count, :missing_plugin_names, :path

	def initialize
		@last_save_time = Time.now
		clear
		@change_count = 0
		@path = nil
		@missing_plugin_names = []

		$engine.on_clear_objects { clear }
	end

	def changed?
		@change_count > 0
	end

	def changed!
		@change_count += 1
		changed_notify(@change_count)
	end

	def not_changed!
		if @change_count != 0
			@change_count = 0
			changed_notify(@change_count)
		end
	end

	def clear
		# remove tags from all objects
		OBJECT_SYMBOLS.each { |obj_type|
			array = instance_variable_get("@#{obj_type}")
			array.each { |obj| obj.clear_tags if obj.respond_to? :clear_tags } if array
		}
		# set all to []
		OBJECT_SYMBOLS.each { |obj_type| instance_variable_set("@#{obj_type}", []) }
	end

	def time_since_save
		Time.now - @last_save_time
	end

	def file_path
		if @path
			File.split(@path).first
		end
	end

	def load_from_path(path)
		clear
		append_from_path(path)
		@path = path
		not_changed!		# A freshly loaded project should not be marked 'changed'
		self
	end

	def append_from_path(path)
		File.open(path, 'r') { |file|
			append_from_file(file)
		}
	end

	def append_from_data(data)
		append_from_file(data)
	end

	def save_to_path(path)
		if save_copy_to_path(path)
			@path = path
			@last_save_time = Time.now
			not_changed!
			true
		else
			false
		end
	end

	def save_copy_to_path(path)
		# save to a .tmp file first, and once that is known to work,
		tmp_path = path + '.tmp'
		File.open(tmp_path, 'w+') { |tmp_file|
			save_to_file(tmp_file)
			File.mv(tmp_path, path)
			return true
		}
		return false
	end

	def hardwire!
		# Remove all user objects that aren't enabled-- why bother processing them forever?
		each_user_object_array { |array|
			array.delete_if { |uo| !uo.is_enabled? }
		}
		# Let remaining objects hardwire themselves
		each_user_object { |uo| uo.hardwire! }
	end

	def each_user_object_array
		OBJECT_SYMBOLS.each { |obj_type|
			yield instance_variable_get("@#{obj_type}")
		}
	end

	def each_user_object
		OBJECT_SYMBOLS.each { |obj_type|
			instance_variable_get("@#{obj_type}").each { |user_object|
				yield user_object
				if user_object.respond_to? :effects
					user_object.effects.each { |effect|
						yield effect
					}
				end
			}
		}
	end

	def serialize
		data = ''
		saved_objects = {:version => FILE_VERSION}
		OBJECT_SYMBOLS.each { |obj_type| saved_objects[obj_type] = self.send("#{obj_type}") }
		ZAML.dump(saved_objects, data)
		data
	end

	# Hack to inform the Taggable module when a new object tagged is inserted
	# This is handled in the Project because it is the authority on the object order
	def update_tags_for_object_class(klass)
		obj_type = CLASS_TO_OBJECT_SYMBOL[klass]
		objs = instance_variable_get("@#{obj_type}")
		return if (objs.nil? or objs.empty?)
		klass.sort_tagged_objects { |a,b| (objs.index(a) || 0) <=> (objs.index(b) || 0) } # TODO: slow!!!
	end

private

	def save_to_file(file)
		file << serialize
		file.flush

		# For comparison:
		#File.open('yamltest.luz', 'w+') { |file|
		#	YAML.dump(saved_objects, file)
		#}
	end

	def append_from_file(file)
		loaded_objects = YAML.load(file)

		throw "version number '#{loaded_objects[:version]}' should be '#{FILE_VERSION}'" unless loaded_objects[:version] == FILE_VERSION

		@missing_plugin_names.clear
		OBJECT_SYMBOLS.each { |obj_type|
			loaded_objects[obj_type] ||= []
			throw "expected array for #{obj_type.to_s} list (was #{loaded_objects[obj_type].class})" unless loaded_objects[obj_type].is_a? Array

			# clean out any YAML::Objects we find
			loaded_objects[obj_type].delete_if { |parent_object|
				if parent_object.is_a? YAML::Object
					@missing_plugin_names << "#{parent_object.class} (object: #{parent_object.ivars['title']})"
					true
				else
					parent_object.effects.delete_if { |child_object|
						if child_object.is_a? YAML::Object
							@missing_plugin_names << "#{child_object.class} (in object: #{parent_object.title})"
							true
						else
							false
						end
					} if parent_object.respond_to? :effects
					false		# don't delete parent
				end
			}

			# add in
			instance_variable_get("@#{obj_type}").concat(loaded_objects[obj_type])
		}

		@last_save_time = Time.now
		$engine.reinitialize_user_objects
		update_tags
	end

	def update_tags
		OBJECT_SYMBOLS.each { |obj_type|
			objs = instance_variable_get("@#{obj_type}")
			next if objs.empty?
			next unless objs.first.class.respond_to? :sort_tagged_objects

			klass = OBJECT_SYMBOL_TO_CLASS[obj_type]
			klass.sort_tagged_objects { |a,b| (objs.index(a) || 0) <=> (objs.index(b) || 0) } # TODO: use a.index <=> b.index when that is added to UOs
		}
	end
end
