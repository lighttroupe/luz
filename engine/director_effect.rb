multi_require 'child_user_object', 'drawing'

class DirectorEffect < ChildUserObject
	include Drawing

	attr_accessor :director, :layer_index, :total_layers		# set just before render time

	def after_load
		set_default_instance_variables(:enabled => true)
		super
	end

	# default implementation just yields once (renders scene once)
	def render
		yield
	end
end
