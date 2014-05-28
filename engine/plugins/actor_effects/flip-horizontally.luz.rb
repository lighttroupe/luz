class ActorEffectFlipHorizontally < ActorEffect
	title				"Flip Horizontally"
	description "Flips actor horizontally."

	category :transform

	def render
		with_scale(-1, 1) {
			yield
		}
	end
end
