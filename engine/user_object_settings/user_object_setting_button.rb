require 'user_object_setting'

class UserObjectSettingButton < UserObjectSetting
	attr_accessor :button

	def to_yaml_properties
		super + ['@button']
	end

	def immediate_value
		@button
	end

	def summary
		summary_format(@button)
	end
end
