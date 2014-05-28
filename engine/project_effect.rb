require 'child_user_object'

class ProjectEffect < ChildUserObject
	include Drawing

	empty_method :pretick, :tick

	def render
		yield
	end
end

