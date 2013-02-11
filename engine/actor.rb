 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

require 'user_object', 'actor_effect', 'color', 'taggable', 'drawing'

class Actor < ParentUserObject
	include Taggable
	include Drawing

	DEFAULT_X, DEFAULT_Y = 0.0, 0.0
	DEFAULT_WIDTH, DEFAULT_HEIGHT = 1.0, 1.0
	WIDTH, HEIGHT = 1.0, 1.0
	RADIUS = 0.5 		# (used by children)

	###################################################################
	# Class-level functions
	###################################################################
	dsl_flag :cache_rendering

	def self.available_categories
		[:transform,:color,:child_producer,:child_consumer,:canvas,:special]
	end

	###################################################################
	# Object-level functions
	###################################################################
	empty_method :render

	attr_accessor :x, :y

	def z
		0.0		# Actors live in 2D.  This just makes us easy to work with. :)
	end

	def to_yaml_properties
		['@x', '@y'] + tag_instance_variables + super
	end

	def after_load
		set_default_instance_variables(:x => DEFAULT_X, :y => DEFAULT_Y, :width => DEFAULT_WIDTH, :height => DEFAULT_HEIGHT, :enabled => true)
		super
		after_load_tag_class_registration
		clear_cache
	end

	def before_delete
		clear_tags
		super
	end

	def deep_clone(*args)
		clear_cache		# We don't want to clone our GL cache
		super(*args)
	end

	def clear_cache
		GL.DeleteLists(@display_list, 1) if @display_list
		@display_list = nil
		self
	end

	###################################################################
	# Render
	###################################################################

	empty_method :tick
	$actor_render_stack ||= []
	ACTOR_RENDER_STACK_LIMIT = 20
	def render!
		return if $actor_render_stack.size > ACTOR_RENDER_STACK_LIMIT
		$actor_render_stack.push(self)

		user_object_try {
			# resolve_settings, and if it returns true (something changed) and we're using caching, clear it now
			clear_cache if resolve_settings and self.class.cache_rendering?
			tick!
			with_translation(@x, @y) {
				# TODO: add rotation with numbers from user point-and-click control?
				render_recursive {
					render_after_effects
				}
			}
		}

		$actor_render_stack.pop
	end

	def update_offscreen_buffer!
		@offscreen_buffer.using {
			render!
		}
	end

	#
	# Render groups
	#
	NUMBER_OF_RENDER_GROUPS = 6
	def render_group_number
		@render_group_number ||= rand(NUMBER_OF_RENDER_GROUPS)+1
	end

	def update_offscreen_buffer?
		(($env[:frame_number] % NUMBER_OF_RENDER_GROUPS)+1) == render_group_number		# staggered
	end

	#
	# ...
	#
	def init_offscreen_buffer
		return if @offscreen_buffer
		@offscreen_buffer = get_offscreen_buffer(framebuffer_image_size)
		update_offscreen_buffer!
	end

	def framebuffer_image_size
		:medium		# see drawing_framebuffer_objects.rb
	end

	def with_image
		init_offscreen_buffer
		if @offscreen_buffer
			update_offscreen_buffer! if update_offscreen_buffer?
			@offscreen_buffer.with_image {
				yield
			}
		end
	end

	# Calls render() on effect at 'effect_index', continuing effects
	# chain once for each time it yields

	def render_recursive(effect_index = 0, &proc)
		if (effect_index and effect = effects[effect_index])
			if !effect.usable?
				# Simply skip this effect
				render_recursive(effect_index + 1, &proc)
			else
				effect.parent_user_object = self
				$engine.user_object_try(effect) {
					effect.resolve_settings
					effect.tick!

					# Each time effect.render yields, render remaining effects, then
					# finally the drawable object, using whatever GL state the effects set
					effect.render { |*options|		# first and only param is options hash
						if o=options[0]
							with_env_hash(o) {
								render_recursive(effect_index + 1, &proc)	# next effect in line
							}
						else
							render_recursive(effect_index + 1, &proc)	# next effect in line
						end
					}
				}
				render_recursive(effect_index + 1, &proc) if effect.crashy? # continue to next effect in line if it *just* crashed
				effect.parent_user_object = nil		# children shouldn't store links to parents (breaks cloning, etc.)
			end
		else
			# we've reached the end of the effects chain
			proc.call
		end
	end

	def valid_child_class?(klass)
		klass.ancestors.include? ActorEffect
	end

	def with_canvas
		# stub
	end

private

	def render_after_effects
		with_compiled_shader {
			if self.class.cache_rendering?
				@display_list ||= GL.RenderToList { render }
				GL.CallList(@display_list)
			else
				render
			end
		}
	end
end
