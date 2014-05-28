class ActorEffectHideRight < ActorEffect
	title				"Hide from Right"
	description "Hides actor starting from the right."

	categories :transform

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		return yield if amount == 0.0

		with_clip_plane([-1.0, 0.0, 0.0, 0.5 - amount]) {
			yield
		}
	end
end
