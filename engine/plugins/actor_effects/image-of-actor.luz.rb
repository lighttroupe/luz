class ActorEffectImageOfActor < ActorEffect
	title				"Image of Actor"
	description "Renders chosen actor to an offscreen image, then applies that image to this actor."

	categories :color

	setting 'actor', :actor, :summary => true

	def render
		with_offscreen_buffer { |buffer|
			# draw chosen actor to texture
			buffer.using {
				actor.one { |actor| actor.render }
			}

			# continue effect chain with this buffer
			buffer.with_image {
				yield
			}
		}
	end
end
