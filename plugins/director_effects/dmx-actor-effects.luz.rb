 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 ###############################################################################

class DirectorEffectDMXActorEffects < DirectorEffect
	title				"DMX Actor Effects"
	description "Combines a Director full of DMX light plugins with an Actor that sets colors."

	hint "Use plugins like Theme Children in the Actor, as the 'child number' will be set for each light."

	setting 'director', :director, :summary => true
	setting 'actor', :actor, :summary => true

	def tick
		director.one { |dmx_director|
			lights = dmx_director.effects
			actor.one { |actor_effects|
				with_env(:total_children, lights.size) {			# this can have an effect on the resulting color set
					lights.each_with_index { |light, index|
						$engine.user_object_try(light) {					# this ensures the plugin is usable and blames it for any exceptions from here on in
							with_env(:child_index, index) {					# this can have an effect on the resulting color set
								actor_effects.render_recursive {			# run actor's effects, and when they're done...
									color = GL.GetColorArray						# ...read the final color and send it to the DMX plugin (respecting alpha!)
									light.resolve_settings
									light.red, light.green, light.blue = color[0]*color[3], color[1]*color[3], color[2]*color[3]		# NOTE: assumes DMX plugins have 'red' 'green' 'blue' methods
									light.tick													# let plugin do its work
								}
							}
						}
					}
				}
			}
		}
	end
end
