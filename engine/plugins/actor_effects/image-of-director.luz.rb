class ActorEffectImageOfDirector < ActorEffect
	title				"Image of Director"
	description "Renders chosen director to an offscreen image, then applies that image to this actor."

	categories :color

	setting 'director', :director, :summary => true

	def render
		with_offscreen_buffer { |buffer|
			# draw chosen actor to texture
			buffer.using {
				director.one { |director| director.render! }
			}

			# continue effect chain with this buffer
			buffer.with_image {
				yield
			}
		}
	end
end
