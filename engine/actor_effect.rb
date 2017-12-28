multi_require 'child_user_object', 'drawing'

class ActorEffect < ChildUserObject
	include Drawing

	RADIUS = 0.5 		# (used by children)

	attr_accessor :parent_user_object  	# set just before render time

	def self.new_renderer
		GuiUserObjectClassRenderer.new(self)
	end
	def new_renderer
		GuiActorEffectRenderer.new(self)
	end

	def after_load
		set_default_instance_variables(:enabled => true)
		super
	end

	#
	# helper methods for use inside plugin tick/render methods
	#
	def child_index
		$env[:child_index] || 0
	end

	def total_children
		$env[:total_children] || 1
	end

	def child_number
		child_index + 1
	end

	#
	# default implementations
	#
	def render
		yield		# dfeault just renders Actor once (ie does nothing)
	end
end
