require 'user_object_setting'

class UserObjectSettingString < UserObjectSetting
	attr_accessor :string

	def to_yaml_properties
		['@string'] + super
	end

	def immediate_value
		@string.to_s
	end
end

