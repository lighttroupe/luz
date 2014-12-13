require 'user_object_setting'	#,'theme_combobox'

class UserObjectSettingTheme < UserObjectSetting
	def to_yaml_properties
		['@theme'] + super
	end

	def after_load
		@theme ||= $engine.project.themes.first
		super
	end

	def immediate_value
		@theme
	end

	def summary
		summary_format(@theme.title) if @theme
	end
end

