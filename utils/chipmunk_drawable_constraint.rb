#
# Note that DrawableObject used to be a struct and retains much of the feel of one. The transition to full object status is ongoing.
#
class DrawableConstraint
	attr_accessor :constraint, :level_object, :render_actor, :draw_proc, :fully_static
	attr_accessor :exited_at, :scheduled_exit_at, :display_list, :sound_id, :angle, :body, :shape, :activation_count		# always nil, only there for compatibility with DrawableObject

	empty_method :update!

	def initialize(simulator, constraint, level_object, render_actor, draw_proc, fully_static)
		@simulator, @constraint, @level_object, @render_actor, @draw_proc, @fully_static = simulator, constraint, level_object, render_actor, draw_proc, fully_static
	end

	def render!
		@draw_proc.call(self) if @draw_proc
	end

	#
	# Shutdown
	#
	def finalize!
	end

	#
	# Debugging
	#
	def letter
		'.'
	end
end
