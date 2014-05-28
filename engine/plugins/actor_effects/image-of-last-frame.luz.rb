class ActorEffectImageOfPreviousFrame < ActorEffect
	title				"Image of Previous Frame"
	description "Applies the final screen image of the previous frame to this actor."

	categories :color

	def render
		with_texture_of_previous_frame(1) {
			yield
		}
	end
end
