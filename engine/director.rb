multi_require 'parent_user_object', 'director_effect'

class Director < ParentUserObject
	title 'Director'

	setting 'offscreen_render_actor', :actor, :summary => 'renders on %'

	require 'drawing'
	include Drawing

	###################################################################
	# Object-level functions
	###################################################################
	def valid_child_class?(klass)
		klass.ancestors.include? DirectorEffect
	end

	attr_accessor :x, :y, :actors, :effects
	empty_method :render

	def to_yaml_properties
		super + ['@actors']
	end

	def default_title
		'New Director'
	end

	def after_load
		set_default_instance_variables(:actors => [], :x => 0.0, :y => 0.0)
		super
	end

	def z
		0.0
	end

	#
	# Render
	#
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
								render
							}
						else
							render
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
				render
			end
		}
	end

	def render
		render_scene_recursive {
			@actors.each { |actor| actor.render! }
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
end
