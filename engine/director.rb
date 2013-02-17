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

require 'parent_user_object', 'director_effect'

class Director < ParentUserObject
	title 'Director'

	setting 'offscreen_render_actor', :actor, :summary => 'renders on %'

	require 'taggable'
	include Taggable

	require 'drawing'
	include Drawing

	ACTOR_RADIUS = 0.5 		# (used by children)

	def self.clear_to_black(clear_bits = GL::COLOR_BUFFER_BIT)
		GL.ClearColor(0,0,0,0)
		GL.Clear(clear_bits)
	end

	###################################################################
	# Object-level functions
	###################################################################
	attr_accessor :x, :y, :effects
	empty_method :render

	def z
		0.0
	end

	def to_yaml_properties
		tag_instance_variables + super
	end

	def default_title
		'New Director'
	end

	def after_load
		set_default_instance_variables(:x => 0.0, :y => 0.0)
		super
		after_load_tag_class_registration
	end

	def before_delete
		clear_tags
		super
	end

	###################################################################
	# Render
	###################################################################
	def render!
		user_object_try {
			if (offscreen_render_actor.present? and not $env[:hit_test] and not $env[:stage])
				with_offscreen_buffer { |buffer|
					# render scene to offscreen buffer
					aspect_scale = $env[:aspect_scale]
					buffer.using {
						if aspect_scale
							# make sure our 1x1 shape fills screen by rendering smaller... 
							with_scale(1.0/aspect_scale, 1.0/aspect_scale) {
								render_scene_recursive
							}
						else
							render_scene_recursive
						end
					}

					# render chosen actor using offscreen buffer as a texture
					buffer.with_image {
						if aspect_scale
							# ...and scaling larger on display
							with_scale(aspect_scale, aspect_scale) {
								offscreen_render_actor.render
							}
						else
							offscreen_render_actor.render
						end
					}
				}
			else
				render_scene_recursive
			end
		}
	end

	def render_scene_recursive(effect_index = 0, options = {}, &proc)
		if (effect_index and effect = effects[effect_index])
			if !effect.usable?
				render_scene_recursive(effect_index + 1, options, &proc)		# Skip this effect
			else
				$engine.user_object_try(effect) {
					effect.resolve_settings
					effect.tick!
					effect.render {
						render_scene_recursive(effect_index + 1, options, &proc)
					}
				}
			end
		else
			# reached bottom of list inside yields
			yield if block_given?
		end
	end

	def valid_child_class?(klass)
		klass.ancestors.include? DirectorEffect
	end

end
