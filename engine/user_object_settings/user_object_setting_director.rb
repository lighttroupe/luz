require 'user_object_setting'

class UserObjectSettingDirector < UserObjectSetting
	attr_accessor :director

	def to_yaml_properties
		super + ['@director']
	end

	def render
		one { |director|
			if (@enable_render_on_actor && @render_on_actor)
				with_offscreen_buffer { |buffer|
					# save future actor renders to buffer
					buffer.using {
						director.render!
					}

					# render buffer on chosen actor
					buffer.with_image {
						@render_on_actor.render!
					}
				}
			else
				director.render!
			end
		}
	end

	def one
		yield @director if @director
	end

	def summary
		summary_format(@director.title) if @director
	end
end
