require 'user_object'

class ParentUserObject < UserObject
	attr_accessor :effects

	def to_yaml_properties
		super + ['@effects']
	end

	def after_load
		set_default_instance_variables(:effects => [])
		super
	end
end
