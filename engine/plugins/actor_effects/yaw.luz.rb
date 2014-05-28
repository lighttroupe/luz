class ActorEffectYaw < ActorEffect
	title				'Yaw'
	description "Rotates actor around its Y axis."

	category :transform

	setting 'angle', :float, :default => 0.0..1.0

	def render
		with_yaw(angle) {
			yield
		}
	end
end
