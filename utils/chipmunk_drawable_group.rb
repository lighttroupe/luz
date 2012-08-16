#
# Note that DrawableObject used to be a struct and retains much of the feel of one. The transition to full object status is ongoing.
#
require 'chipmunk_drawable_object'

# TODO: rename DrawableStaticPhysicalGroup < DrawableStaticList
class DrawableGroup < DrawableObject
	require 'chipmunk_render_helpers'
	include ChipmunkRenderHelpers
	include Drawing

	#
	# Class Methods
	#
	def self.suitable?(drawables)
		(drawables.find { |drawable| drawable.fully_static == false }).nil?		# can't support any dynamic
	end

	#
	# Instance Methods
	#
	def initialize(simulator, body, level_object, drawable_objects, draw_proc)
		@simulator, @drawable_objects = simulator, drawable_objects
		@actor_effects = find_actor_by_name(level_object.options[:actor_effects])
		super(simulator, body, shapes=nil, shape_offset=nil, level_object, angle=nil, scale_x=nil, scale_y=nil, render_actor=nil, child_index=nil, draw_proc, fully_static=:group)
	end

	def each_shape(&proc)
		@drawable_objects.each { |obj| obj.each_shape(&proc) }
	end

	#
	# Rendering
	#
	def render!
		with_physical_body_position_and_rotation(self) {
			# Map Feature: 'actor-effects' on groups
			if @actor_effects
				@simulator.with_env_for_actor(self) {
					@actor_effects.render_recursive {
						render_with_display_list
					}
				}
			else
				render_with_display_list
			end
		}
	end

	def render_with_display_list
		@display_list = GL.RenderCached(@display_list) {
			@drawable_objects.each { |drawable|
				drawable.render!
			}
		}
	end

	#
	# Shutdown
	# 
#	def begin_exit!		added when trying to fix a bug, never called. not needed?
#		super
#		@drawable_objects.each { |drawable| drawable.begin_exit! }
#	end

	def finalize!
		super
		@drawable_objects.each { |drawable| drawable.finalize! }
	end

	#
	# Debugging
	#
	def letter
		'g'
	end
end
