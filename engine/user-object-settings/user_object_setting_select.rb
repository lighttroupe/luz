require 'user_object_setting'

class UserObjectSettingSelect < UserObjectSetting
	def to_yaml_properties
		['@selected'] + super
	end

	def after_load
		@selected = @options[:default] unless selected_option
	end

	def immediate_value
		@selected
	end

	def selected_option
		@options[:options].find { |o| o.first == @selected }		# format: [[:sym, 'name'], ...]
	end

	def summary
		option = selected_option
		summary_format((option ? option.last : @selected).to_s)
	end
end
