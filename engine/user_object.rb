load_directory(File.join(Dir.pwd, 'engine', 'user_object_settings'), '**.rb')

class UserObject
	include MethodsForUserObject

	Setting = Struct.new('Setting', :name, :klass, :options)

	@@inherited_classes ||= []

	def self.inherited(klass)
		klass.source_file_path = Kernel.loading_file_path		# record which source file the new class came from
		@@inherited_classes << klass
		super
	end

	def self.inherited_classes
		@@inherited_classes
	end

	#
	# Class-level methods
	#
	class << self
		attr_accessor :source_file_path
	end

	dsl_string :title, :description, :hint
	dsl_set :category, :categories

	def self.available_categories
		[]
	end

	def self.setting(name, klass, options={})
		@settings ||= []

		# Add it to list
		@settings.append_or_replace(Setting.new(name.to_s, klass, options)) { |obj, new| obj.name == new.name }

		#
		# Methods that plugins will use
		#
		self.class_eval <<-end_class_eval
			# How child classes access the (cached) value for this UOS.
			# This allows them to refer to the value multiple times without calculating the value every time.
			def #{name}
				@#{name}_value
			end

			# Queries and saves the value of the UOS on the current frame.
			# Returns the new value.
			def #{name}_resolve
				@#{name}_value = @#{name}_setting.immediate_value
			end

			# A way to set the value, mainly used by scripts that create Effect objects
			def #{name}=(value)
				@#{name}_value = value
			end
			def set_#{name}(value)
				@#{name}_value = value
				self
			end

			# Sometimes we'll need to get at the UOS itself
			def #{name}_setting
				@#{name}_setting
			end
		end_class_eval
	end

	def self.settings
		@settings ||= []
		(self == UserObject ? [] : self.superclass.settings) + @settings	# Returns settings from ourselves & ancestors
	end

	def self.virtual
		@virtual_class = self.class.name
	end

	def self.virtual?
		@virtual_class == self.class.name
	end

	#
	# Object-level methods
	#

	def to_yaml_properties
		['@title', '@enabled'] + self.class.settings.collect { |setting| "@#{setting.name}_setting" }
	end

	def settings
		@settings ||= create_user_object_settings
	end

	empty_method :tick		# override

	def tick!
		return if @last_tick_frame_number == $env[:frame_number]
		user_object_try { tick }
		@last_tick_frame_number = $env[:frame_number]
	end

	def ticked_recently?
		@last_tick_frame_number && (@last_tick_frame_number > ($env[:frame_number] - 2))
	end

	def user_object_try
		$engine.user_object_try(self) { yield }
	end

	# 'crashy' means the plugin threw an exception
	# we notify user and leave it to them to fix the code, change settings, or stop using the problem code
	boolean_accessor :crashy

	# All UserObjects have the concept of being 'enabled', although some don't expose this to users.
	boolean_accessor :enabled

	def usable?
		!@crashy && @enabled
	end

	# All user objects have a 'title', the user-settable name.
	attr_accessor :title

	def default_title
		self.class.title		# eg. default name for a Rectangle is "Rectangle"
	end

	def initialize
		super
		after_load
		resolve_settings
	end

	def after_load
		set_default_instance_variables(:title => default_title, :enabled => true)
		create_user_object_settings
	end

	empty_method :before_delete

	# Create instance variables based on the list of settings
	def create_user_object_settings
		@settings = []
		self.class.settings.each { |setting|
			# NOTE: uses ||= so it doesn't clober UOSs in case of File/Load or plugin reload
			instance_eval("@#{setting.name}_setting ||= new_user_object_setting(setting)", __FILE__, __LINE__)
			instance_eval("@#{setting.name}_setting.options = setting.options", __FILE__, __LINE__)
			instance_eval("@#{setting.name}_setting.parent = self", __FILE__, __LINE__)
			instance_eval("@settings << @#{setting.name}_setting", __FILE__, __LINE__)
		}
		@settings.each { |setting| setting.after_load }
		@settings
	end

	def new_user_object_setting(setting)
		require 'user_object_setting'

		# Create a new UserObjectSetting instance for this setting
		begin
			klass = Kernel.const_get('UserObjectSetting' + setting.klass.to_s.split('_').collect { |s| s.capitalize }.join )
		rescue NameError
			raise "bad user object setting type '#{setting.klass}'"
		end
		klass.new(self, setting.name, setting.options)
	end

	# NOTE: also returns whether any cache-breaking-settings have changed
	def resolve_settings
		# a name => method name lookup, to avoid creating tons of useless Strings		TODO: better way??
		@setting_name_to_resolve_method_hash ||= Hash.new { |hash, key| hash[key] = "#{key}_resolve" }

		breaks_cache = false
		settings.each { |setting|
			breaks_cache = true if ((setting.last_value != self.send(@setting_name_to_resolve_method_hash[setting.name])) && setting.breaks_cache?)
		}
		breaks_cache
	end

	def get_user_object_setting_by_name(name)
		# a name => instance variable name lookup, to avoid creating tons of useless Strings		TODO: better way??
		@setting_name_to_variable_hash ||= Hash.new { |hash, key| hash[key] = "@#{key}_setting" }

		instance_variable_get(@setting_name_to_variable_hash[name])
	end

	def settings_summary
		@settings.collect_non_nil { |setting| setting.summary }
	end

	def valid_child_class?(klass)
		false
	end
end
