multi_require 'user_object', 'child_conditions'

class ChildUserObject < UserObject
	attr_reader :conditions

	def to_yaml_properties
		super + ['@conditions']
	end

	def after_load
		set_default_instance_variables(:conditions => ChildConditions.new)
		super
	end

	def usable?
		@enabled && !@crashy && @conditions.satisfied?
	end
end
