require 'user_object_setting'

class UserObjectSettingSelect < UserObjectSetting
	def to_yaml_properties
		super + ['@selected']
	end

	def after_load
		@selected = @options[:default] unless find_selected_option
		super
	end

	def immediate_value
		@selected
	end

	def find_selected_option
		@options[:options].find { |o| o.first == @selected }		# format: [[:sym, 'name'], ...]
	end

	def summary
		option = find_selected_option
		summary_format((option ? option.last : @selected).to_s)
	end
end
