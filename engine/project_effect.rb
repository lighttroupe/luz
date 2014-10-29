require 'child_user_object'

class ProjectEffect < ChildUserObject
	include Drawing

	empty_method :pretick, :tick

	def pretick!
		user_object_try { pretick }
	end

	def render
		yield
	end
end
