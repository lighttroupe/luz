class ActorEffectMirrorHorizontal < ActorEffect
	title				'Mirror Horizontal'
	description "The left half of the actor is mirrored on the right side."

	categories :transform, :child_producer

	hint "The mirror is fixed, so future movement of the actor will have interesting effects!"

	def render
		# Right
		with_clip_plane([ -1.0, 0.0, 0.0, 0.0]) {
			yield :child_index => 0, :total_children => 2
		}

		# Left
		with_clip_plane([ 1.0, 0.0, 0.0, 0.0]) {
			with_scale(-1, 1) {
				yield :child_index => 1, :total_children => 2
			}
		}
	end
end
