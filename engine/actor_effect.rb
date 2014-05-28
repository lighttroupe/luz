multi_require 'child_user_object', 'drawing'

class ActorEffect < ChildUserObject
	include Drawing

	RADIUS = 0.5 		# (used by children)

	attr_accessor :parent_user_object  	# set just before render time

	def after_load
		set_default_instance_variables(:enabled => true)
		super
	end

	def child_index
		$env[:child_index] || 0
	end

	def total_children
		$env[:total_children] || 1
	end

	def child_number
		child_index + 1
	end

	# default implementation just yields once (= renders the object once)
	def render
		yield
	end
end
