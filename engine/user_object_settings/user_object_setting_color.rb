require 'user_object_setting'

class UserObjectSettingColor < UserObjectSetting
	DEFAULT_COLOR = [1.0,1.0,1.0,1.0]

	attr_accessor :color

	def to_yaml_properties
		super + ['@color']
	end

	def after_load
		set_default_instance_variables(:color => Color.new.set(@options[:default] || DEFAULT_COLOR))
		super
	end

	def immediate_value
		@color
	end
end
