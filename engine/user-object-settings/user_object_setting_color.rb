require 'user_object_setting'

class UserObjectSettingColor < UserObjectSetting
	DEFAULT_COLOR = [1.0,1.0,1.0,1.0]

	attr_accessor :color		# for setting it (usually temporarily for yielding with the color set)

	def to_yaml_properties
		super + ['@color']
	end

	def after_load
		#throw 'color array must contain 3 or 4 Floats from 0.0 to 1.0' if @options[:default] and not (color[0].is_a?(Float) and color[1].is_a?(Float) and color[2].is_a?(Float) and (color[3].nil? or color[3].is_a?(Float))

		color = (@options[:default] || DEFAULT_COLOR)

		@use_alpha = (color.size == 4)		# "cleverly" determine whether to use alpha based on the default value set
		set_default_instance_variables(:color => Color.new.set(color), :type => :literal)
		super
	end

	def immediate_value
		@color
	end
end
