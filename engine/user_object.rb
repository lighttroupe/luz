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

load_directory(File.join(Dir.pwd, 'user-object-settings'), '**.rb')

class UserObject
	Setting = Struct.new('Setting', :name, :klass, :options)

	ICON_WIDTH, ICON_HEIGHT = 24, 24

	@@inherited_classes ||= []

	def self.inherited(klass)
		klass.source_file_path = Kernel.loading_file_path		# record which source file the new class came from
		@@inherited_classes << klass
		super
	end

	def self.inherited_classes
		@@inherited_classes
	end

	def self.text_match?(search_string)
		self.title.downcase.matches?(search_string)
	end

	###################################################################
	# Class-level settings
	###################################################################
	class << self
		attr_accessor :source_file_path
	end

	dsl_string :title, :description, :hint

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
		defined?(@virtual_class) && @virtual_class == self.class.name
	end

	###################################################################
	# Object-level functions
	###################################################################

	attr_accessor :last_exception

	def settings
		@settings ||= create_user_object_settings				# ensure settings have been created (imported projects haven't had their settings created yet)
	end

	# nothing
	empty_method :tick

	def tick!
		return if @last_tick_frame_number == $env[:frame_number]
		user_object_try { tick }
		@last_tick_frame_number = $env[:frame_number]
	end

	def to_yaml_properties
		['@title', '@enabled'] + self.class.settings.collect { |setting| "@#{setting.name}_setting" }
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
		!@crashy and @enabled
	end

	# All user objects have a 'title', the user-settable name.
	attr_accessor :title

	def default_title
		self.class.title		# default name for a Rectangle is "Rectangle"
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

	def hardwire!
		settings.each { |setting| setting.hardwire! }
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
		return klass.new(self, setting.name, setting.options)
	end

	# NOTE: also returns whether any cache-breaking-settings have changed
	def resolve_settings
		# a name => method name lookup, to avoid creating tons of useless Strings		TODO: better way??
		@setting_name_to_resolve_method_hash ||= Hash.new { |hash, key| hash[key] = "#{key}_resolve" }

		breaks_cache = false
		settings.each { |setting|
			breaks_cache = true if ((setting.last_value != self.send(@setting_name_to_resolve_method_hash[setting.name])) and setting.breaks_cache?)
		}
		return breaks_cache
	end

	def get_user_object_setting_by_name(name)
		# a name => instance variable name lookup, to avoid creating tons of useless Strings		TODO: better way??
		@setting_name_to_variable_hash ||= Hash.new { |hash, key| hash[key] = "@#{key}_setting" }

		instance_variable_get(@setting_name_to_variable_hash[name])
	end

	def settings_summary
		@settings.collect_non_nil { |setting| setting.summary }
	end

	def text_match?(search_string)
		self.title.downcase.matches?(search_string)
	end
end
