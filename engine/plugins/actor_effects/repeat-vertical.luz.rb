class ActorEffectRepeatVertical < ActorEffect
	title				"Repeat Vertical"
	description "Draws actor twice, once normally and once flipped vertically."

	category :child_producer

	def render
		# Top
		yield :child_index => 0, :total_children => 2

		# Bottom
		with_scale(1, -1) {
			yield :child_index => 1, :total_children => 2
		}
	end
end
