require 'user_object_setting'

class UserObjectSettingFont < UserObjectSetting
	attr_accessor :font

	def to_yaml_properties
		super + ['@font']
	end

	def immediate_value
		@font
	end
end
