class ActorRoundedRectangle < ActorShape
	title				"Rounded Rectangle"
	description "A rectangle with rounded corners."

	setting 'knob_x', :float, :range => 0.0..1.00, :default => 0.25..1.00, :breaks_cache => true
	setting 'knob_y', :float, :range => 0.0..1.00, :default => 0.25..1.00, :breaks_cache => true
	setting 'detail', :integer, :range => 1..50, :default => 16..50, :breaks_cache => true		# Points on curve

	cache_rendering

	def shape
		yield :shape => Shapes.RoundedRectangle(RADIUS, RADIUS, knob_x, knob_y, detail)
	end
end
