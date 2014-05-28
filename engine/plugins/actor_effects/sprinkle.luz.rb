class ActorEffectSprinkle < ActorEffect
	title				"Sprinkle"
	description "Draws actor many times in random positions within a given radius."

	categories :child_producer

	setting 'number', :integer, :range => 1..1000, :default => 1..2
	setting 'radius', :float, :range => 0.0..100.0, :default => 1.0..2.0

	def render
		@seed ||= Time.now.to_i		# TODO: This should be:  setting 'position', :random, :range => -1.0..1.0
		srand(@seed)		# TODO: remove when we have a :random UOS

		yield :child_index => 0, :total_children => number
		for i in 1...number
			with_translation(rand.scale(-1.0, 1.0) * radius, rand.scale(-1.0, 1.0) * radius) {
				yield :child_index => i, :total_children => number
			}
		end

		srand
	end
end
