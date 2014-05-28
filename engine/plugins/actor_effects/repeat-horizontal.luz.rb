class ActorEffectRepeatHorizontal < ActorEffect
	title				"Repeat Horizontal"
	description "Draws actor twice, once normally and once flipped horizontally."

	category :child_producer

	def render
		# Right
		yield :child_index => 0, :total_children => 2

		# Left
		with_scale(-1, 1) {
			yield :child_index => 1, :total_children => 2
		}
	end
end
