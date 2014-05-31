class ActorEffectHideLeft < ActorEffect
	title				"Hide from Left"
	description "Hides actor starting from the left."

	categories :special

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		return yield if amount == 0.0

		with_clip_plane([1.0, 0.0, 0.0, 0.5 - amount]) {
			yield
		}
	end
end
