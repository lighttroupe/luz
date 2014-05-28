class ActorPolygon < ActorShape
	title				"Polygon"
	description "An N-sided polygon with optional center cutout."

	setting 'sides', :integer, :range => 3..100, :default => 5..100, :breaks_cache => true
	setting 'cutout_size', :float, :range => 0.0..1.00, :default => 0.00..1.0, :breaks_cache => true

	cache_rendering

	def shape
		shape = [Shapes.Ring(RADIUS, sides)]
		shape << shape.first.dup.multiply_each(cutout_size) unless cutout_size == 0.0
		yield :shape => shape
	end
end
