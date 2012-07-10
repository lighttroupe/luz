#
# Note that DrawableObject used to be a struct and retains much of the feel of one. The transition to full object status is ongoing.
#
class DrawableStaticList
	require 'chipmunk_render_helpers'
	include ChipmunkRenderHelpers
	include Drawing

	#
	# Class Methods
	#
	def self.suitable?(drawable)
		drawable.fully_static?		# TODO: rename fully_static and make it all symbols :dynamic, :partial, :static
	end

	#
	# Instance Methods
	#
	attr_accessor :constraint, :level_object, :render_actor, :draw_proc, :fully_static
	attr_accessor :exited_at, :scheduled_exit_at, :display_list, :sound_id, :angle, :body, :shape, :activation_count		# always nil, only there for compatibility with DrawableObject

	empty_method :update!

	def initialize(simulator, drawable_objects, draw_proc)
		@simulator, @drawable_objects, @draw_proc = simulator, drawable_objects, draw_proc
	end

	#
	# Rendering
	#
	def render!
		@display_list = GL.RenderCached(@display_list) {
			@drawable_objects.each { |drawable|
				drawable.render!
			}
		}
	end

	#
	# Shutdown
	#
	def finalize!
		@drawable_objects.each { |drawable| drawable.finalize! }
	end

	#
	# Debugging
	#
	def letter
		'L'
	end
end
