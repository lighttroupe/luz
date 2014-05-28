class ActorEffectPitch < ActorEffect
	title				'Pitch'
	description "Rotates actor around its X axis."

	category :transform

	setting 'angle', :float, :default => 0.0..1.0

	def render
		with_pitch(angle) {
			yield
		}
	end
end
