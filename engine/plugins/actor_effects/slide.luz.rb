class ActorEffectSlide < ActorEffect
	title				"Slide"
	description "Moves actor in a chosen direction."

	category :transform

	setting 'amount', :float, :default => 0.0..1.0
	setting 'angle', :float, :default => 0.0..1.0

	def render
		with_angle_slide(angle, amount) {
			yield
		}
	end
end
