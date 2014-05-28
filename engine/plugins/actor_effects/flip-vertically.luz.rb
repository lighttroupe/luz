class ActorEffectFlipVertically < ActorEffect
	title				"Flip Vertically"
	description "Flips actor vertically."

	category :transform

	def render
		with_scale(1, -1) {
			yield
		}
	end
end
