require 'user_object_setting'

class UserObjectSettingCurve < UserObjectSetting
	attr_accessor :curve

	def to_yaml_properties
		super + ['@curve']
	end

	def after_load
		@curve ||= $engine.project.curves.first		# This is a hack-- how should we handle this?
		super
	end

	def immediate_value
		@curve
	end

	def summary
		summary_format(@curve.title) if @curve
	end
end
