class ActorEffectRoll < ActorEffect
	title				'Roll'
	description "Rotates actor clockwise around its Z axis."

	category :transform

	setting 'amount', :float, :default => 0.0..1.0, :digits => 3

	def render
		with_roll(amount) {
			yield
		}
	end
end
