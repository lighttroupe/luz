class ActorRectangle < ActorShape
	title				"Rectangle"
	description "A rectangle with optional center cutout.\n\nUseful for skinning with images and video."

	setting 'hole_size', :float, :range => 0.0..1.00, :default => 0.00..1.0, :breaks_cache => true

	cache_rendering

	def shape
		s = [-RADIUS, -RADIUS, -RADIUS, RADIUS, RADIUS, RADIUS, RADIUS, -RADIUS]
		s = [s, s.dup.multiply_each(hole_size)] unless hole_size == 0.0
		yield :shape => s
	end
end
