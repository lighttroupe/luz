class ActorEffectShake < ActorEffect
	title				"Shake"
	description "Shakes actor by moving it to a random location within given distance on each frame."

	category :transform

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..0.05, :digits => 3

	def render
		with_angle_slide(rand, amount) {
			yield
		}
	end
end
