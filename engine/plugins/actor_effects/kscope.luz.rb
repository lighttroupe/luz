class ActorEffectKScope < ActorEffect
	title				"KScope"
	description "Kaleidescope effect."

	categories :transform, :child_producer

	setting 'folds', :integer, :range => 0..100, :default => 1..2

	def render
		folds_doubled = folds * 2
		return yield if folds_doubled == 0

		# Rotate left half of one slice
		start_radians = RADIANS_UP - ((RADIANS_PER_CIRCLE / folds_doubled) / 2.0)
		end_radians = start_radians + (RADIANS_PER_CIRCLE / folds_doubled)

		for i in (0...folds_doubled)
			# The rotation here affects the clip planes and the actor
			with_roll(i * -(1.0 / folds_doubled)) {
				# Create the two clip planes (a V-shape)
				with_clip_plane([-Math.sin(start_radians), -Math.cos(start_radians), 0.0, 0.0]) {
					with_clip_plane([Math.sin(end_radians), Math.cos(end_radians), 0.0, 0.0]) {
						# Flip every other slice left-right so the edges mesh perfectly
						if i.odd?
							with_scale(-1, 1) { yield :child_index => i, :total_children => folds_doubled }
						else
							yield :child_index => i, :total_children => folds_doubled
						end
					}
				}
			}
		end
	end
end
