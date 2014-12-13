require 'user_object_setting'

class UserObjectSettingVariable < UserObjectSetting
	attr_reader :variable

	def to_yaml_properties
		['@variable'] + super
	end

	def immediate_value
		@variable ? @variable.do_value : 0.0
	end

	def last_value
		@variable ? @variable.last_value : 0.0
	end

	def summary
		summary_format(@variable.title) if @variable
	end
end
