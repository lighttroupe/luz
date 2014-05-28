require 'user_object_setting'

class UserObjectSettingFont < UserObjectSetting
	def to_yaml_properties
		super + ['@font']
	end

	def immediate_value
		@font
	end
end
