class ActorEffectGhost < ActorEffect
	title				"Ghost"
	description "Adds a floating ghost of the actor above it, with controllable size, angle, distance, and alpha."

	hint "The original actor is child 1 and the ghost is child 2."

	categories :child_producer

	setting 'size', :float, :default => 1.0..2.0
	setting 'distance', :float, :default => 0.0..1.0
	setting 'angle', :float, :default => 0.0..1.0
	setting 'alpha', :float, :range => 0.0..1.0, :default => 0.25..1.0

	def render
		yield :child_index => 0, :total_children => 2		# Normal

		with_angle_slide(angle, distance ) {
			with_scale(size) {
				with_multiplied_alpha(alpha) {
					yield :child_index => 1, :total_children => 2		# Ghost
				}
			}
		}
	end
end
