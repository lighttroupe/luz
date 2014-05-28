class ActorStarFlower < ActorShape
	title				"Star Flower"
	description "A pointy or rounded star shape with controllable number of arms and inner radius."

	setting 'arms', :integer, :range => 2..100, :default => 5..100, :breaks_cache => true
	setting 'radius', :float, :range => -2.0..2.0, :default => 0.2..1.0, :breaks_cache => true
	setting 'detail', :integer, :range => 1..100, :default => 50..100, :breaks_cache => true		# Points between arms

	cache_rendering

	def shape
		yield :shape => Shapes.VariableCircle(arms, detail + 1) {
				|fuzzy| (radius * RADIUS) + (fuzzy_cosine(fuzzy) * (RADIUS - (radius * RADIUS)))
			}
	end
end
