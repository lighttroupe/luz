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
					buffer.using {
						director.render!
					}
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
		yield @director if @director && block_given?
		@director
	end

	def summary
		summary_format(@director.title) if @director
	end
end
