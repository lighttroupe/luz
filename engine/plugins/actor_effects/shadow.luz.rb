class ActorEffectShadow < ActorEffect
	title				"Shadow"
	description "Draws a shadow below the actor."

	categories :child_producer

	setting 'alpha', :float, :range => 0.0..1.0, :default => 0.5..1.0
	setting 'size', :float, :range => 0.0..100.0, :default => 1.0..2.0
	setting 'angle', :float, :range => -1.0..1.0, :default => 0.0..1.0
	setting 'distance', :float, :range => -100.0..100.0, :default => 0.0..1.0

	def render
		with_angle_slide(angle, distance) {
			with_scale(size) {
				with_multiplied_alpha(alpha) {
					yield :child_index => 1, :total_children => 2
				}
			}
		}
		yield :child_index => 0, :total_children => 2 		# The normal actor
	end
end
