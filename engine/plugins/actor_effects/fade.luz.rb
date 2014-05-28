class ActorEffectFade < ActorEffect
	title				"Fade"
	description "Fades actor out."

	categories :color

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		return if amount == 1.0

		with_multiplied_alpha(1.0 - amount) {
			yield
		}
	end
end
