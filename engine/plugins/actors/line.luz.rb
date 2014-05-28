class ActorLine < ActorShape
	title				"Line"
	description "A line with controllable length and width."

	setting 'length', :float, :range => 0..100.0, :default => 0.5..1.0, :breaks_cache => true
	setting 'width', :float, :range => 0.0..100.0, :default => 0.25..100.0, :breaks_cache => true
	setting 'detail', :integer, :range => 2..100, :default => 100..100, :breaks_cache => true

	cache_rendering

	def shape
		yield :shape => Path.generate { |s|
			s.start_at(width / 2, 0)
			s.arc_to(0.0, 0.0, width / 2, width / 2, 0.0, -Math::PI, detail)
			s.line_to(-width / 2, length)
			s.arc_to(0.0, length, width / 2, width / 2, Math::PI, 0.0, detail)
			s.line_to(width/2, 0)
		}
	end
end
