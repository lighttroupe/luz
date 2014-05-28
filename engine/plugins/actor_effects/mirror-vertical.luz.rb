class ActorEffectMirrorVertical < ActorEffect
	title				"Mirror Vertical"
	description "The top half of the actor is mirrored on the bottom side."

	categories :transform, :child_producer

	def render
		# Top
		with_clip_plane([0.0,  1.0, 0.0, 0.0]) {
			yield :child_index => 0, :total_children => 2
		}

		# Bottom
		with_clip_plane([0.0, -1.0, 0.0, 0.0]) {
			with_scale(1, -1) {
				yield :child_index => 1, :total_children => 2
			}
		}
	end
end
