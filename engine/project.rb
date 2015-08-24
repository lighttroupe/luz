multi_require 'callbacks', 'project_effect', 'yaml', 'zaml'

# For File.mv
require 'fileutils'	# ruby 1.9
#YAML::ENGINE.yamler = 'syck' if defined?(YAML::ENGINE) && YAML::ENGINE.respond_to?(:yamler)

require 'callbacks'

class Project < UserObject
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

	# For use by editor
	def title
		'Project Plugins'
	end

	attr_reader :path, :change_count, :missing_plugin_names, :effects

	def initialize
		@last_save_time = Time.now
		clear
		@missing_plugin_names = []
	end

	def clear
		# set all to []
		OBJECT_SYMBOLS.each { |obj_type| instance_variable_set("@#{obj_type}", []) }
		@change_count = 0
		@path = nil
	end

	def valid_child_class?(klass)
		klass.ancestors.include? ProjectEffect
	end

	#
	# Change monitoring
	#
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

	def time_since_save
		Time.now - @last_save_time
	end

	def file_path
		if @path
			File.split(@path).first
		end
	end

	def media_file_path(absolute_path)
		raise ArgumentError.new("expected #{absolute_path} to exist") unless File.exists?(absolute_path)

		puts "[#{self.file_path}] media_file_path(#{absolute_path}) => "
		if absolute_path.has_prefix?(self.file_path)
			puts absolute_path
			absolute_path
		else
			destination = File.join(file_path, File.basename(absolute_path))
			FileUtils.cp(absolute_path, destination)
			puts destination
			destination
		end
	end

	#
	# Loading
	#
	def load_from_path(path)
		path = File.absolute_path(path)
		clear
		append_from_path(path)
		@path = path
		not_changed!		# A freshly loaded project should not be marked 'changed'
		true
	end

	def append_from_path(path)
		File.open(path, 'r') { |file|
			append_from_file(file)
		}
	end

	def append_from_data(data)
		append_from_file(data)
	end

	#
	# Saving
	#
	def save
		save_copy_to_path(@path)
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
			if save_to_file(tmp_file)
				File.rename(tmp_path, path)
				return true
			end
		}
		false
	end

	#
	# Iterating
	#
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

private

	def save_to_file(file)
		begin
			file << serialize
			file.flush
			return true
		rescue Exception => e
			$gui.negative_message e.message
			return false
		end

		# For comparison:
		#File.open('yamltest.luz', 'w+') { |file|
		#	YAML.dump(saved_objects, file)
		#}
	end

	def serialize
		data = ''
		saved_objects = {:version => FILE_VERSION}
		OBJECT_SYMBOLS.each { |obj_type| saved_objects[obj_type] = self.send("#{obj_type}") }
		ZAML.dump(saved_objects, data)
		data
	end

	def append_from_file(file)
		loaded_objects = Syck.load(file)

		raise "version number '#{loaded_objects[:version]}' should be '#{FILE_VERSION}'" unless loaded_objects[:version] == FILE_VERSION

		@missing_plugin_names.clear
		OBJECT_SYMBOLS.each { |obj_type|
			loaded_objects[obj_type] ||= []
			raise "expected array for #{obj_type.to_s} list (was #{loaded_objects[obj_type].class})" unless loaded_objects[obj_type].is_a? Array

			# clean out any YAML::Objects we find
			loaded_objects[obj_type].delete_if { |parent_object|
				if parent_object.is_a? Syck::Object
					@missing_plugin_names << "#{parent_object.class} (object: #{parent_object.ivars['title']})"
					true
				else
					parent_object.effects.delete_if { |child_object|
						if child_object.is_a? Syck::Object
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
