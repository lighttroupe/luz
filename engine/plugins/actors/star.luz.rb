class ActorStar < ActorShape
	title				"Star"
	description "A star with controllable number of arms and optional center cutout."

	setting 'arms', :integer, :range => 2..100, :default => 5..100, :breaks_cache => true
	setting 'radius', :float, :range => 0.0..1.0, :default => 0.25..1.0, :breaks_cache => true
	setting 'cutout_size', :float, :range => 0.0..1.00, :default => 0.00..1.0, :breaks_cache => true

	cache_rendering

	def shape
		shape = [Shapes.VariableCircle(arms, 2) { |fuzzy| (radius * RADIUS) + (fuzzy_cosine(fuzzy) * (RADIUS - (radius * RADIUS))) }]
		shape << shape.first.dup.multiply_each(cutout_size) unless cutout_size == 0.0
		yield :shape => shape
	end
end
