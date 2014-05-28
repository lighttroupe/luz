require 'user_object_setting_numeric'

class UserObjectSettingInteger < UserObjectSettingNumeric
	ANIMATION_REPEAT_NUMBER_RANGE = ENTER_REPEAT_NUMBER_RANGE = EXIT_REPEAT_NUMBER_RANGE = 0.1..999
	ANIMATION_STEP_NUMBER_RANGE = 1..999
	ANIMATION_TYPE_OPTIONS = [[:none, 'No Animation'], [:repeat, 'One-way'], [:reverse, 'Ping-pong']]

	attr_accessor :animation_min, :animation_type, :animation_max, :animation_step, :animation_repeat_number, :animation_repeat_unit

	def to_yaml_properties
		super + ['@animation_min']
	end

	def after_load
		@options[:default] = (@options[:default] or @options[:range] or 1..2)

		set_default_instance_variables(:animation_min => @options[:default].first, :animation_step => 1, :animation_type => :none)

		@min ||= @options[:range].first
		@max ||= @options[:range].last

		super
	end

	def immediate_value
		@last_value = @animation_min
	end

	def summary
		summary_format(@animation_min.to_s)
	end
end
