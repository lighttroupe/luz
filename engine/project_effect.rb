require 'child_user_object'

class ProjectEffect < ChildUserObject
	include Drawing

	empty_method :pretick, :tick

	def self.new_renderer
		GuiUserObjectClassRenderer.new(self)
	end
	def new_renderer
		GuiProjectEffectRenderer.new(self)
	end

	def pretick!
		user_object_try { pretick }
	end

	def render
		yield
	end
end
