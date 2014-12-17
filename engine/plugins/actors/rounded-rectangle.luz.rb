class ActorRoundedRectangle < ActorShape
	title				"Rounded Rectangle"
	description "A rectangle with rounded corners."

	setting 'knob_x', :float, :range => 0.0..1.00, :default => 0.25..1.00, :breaks_cache => true
	setting 'knob_y', :float, :range => 0.0..1.00, :default => 0.25..1.00, :breaks_cache => true
	setting 'detail', :integer, :range => 1..50, :default => 16..50, :breaks_cache => true		# Points on curve
	setting 'cutout_size', :float, :range => 0.0..1.00, :default => 0.00..1.0, :breaks_cache => true

	cache_rendering

	def shape
		s = Shapes.RoundedRectangle(RADIUS, RADIUS, knob_x, knob_y, detail)
		s = [s, s.dup.multiply_each(cutout_size)] unless cutout_size == 0.0
		yield :shape => s
	end
end
