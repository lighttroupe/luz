multi_require 'child_user_object', 'drawing'

class DirectorEffect < ChildUserObject
	include Drawing

	attr_accessor :director		# set just before render time

	def self.new_renderer
		GuiUserObjectClassRenderer.new(self)
	end
	def new_renderer
		GuiDirectorEffectRenderer.new(self)
	end

	def after_load
		set_default_instance_variables(:enabled => true)
		super
	end

	# default implementation just yields once (renders scene once)
	def render
		yield
	end
end
