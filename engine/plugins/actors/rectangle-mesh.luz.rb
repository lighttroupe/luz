class ActorRectangleMesh < ActorShape
	title				"Rectangle Mesh"
	description "A rectangle with additional vertices, suitable for use with effects that warp vertices."

	cache_rendering

	setting 'density', :integer, :range => 2..100, :default => 5..100, :breaks_cache => true

	def shape
		shape = []
		d = density
		for y in (-d..d-1)
			for x in (-d..d)
				shape << x.to_f / (d * 2.0)
				shape << y.to_f / (d * 2.0)

				shape << (x).to_f / (d * 2.0)
				shape << (y+1).to_f / (d * 2.0)
			end
		end

		yield :type => :triangle_strip, :shape => shape
	end
end
