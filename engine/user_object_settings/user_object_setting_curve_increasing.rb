require 'user_object_setting_numeric'

class UserObjectSettingCurveIncreasing < UserObjectSetting
	attr_accessor :curve

	def to_yaml_properties
		super + ['@curve']
	end

	def after_load
		@curve ||= $engine.project.curves.first		# This is a hack-- how should we handle this?
		super
	end

	# enter and exit times are in engine-time (seconds, float)
	def immediate_value
		@curve
	end
end
