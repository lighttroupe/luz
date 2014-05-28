class ActorCircle < ActorEffect
	title				"Circle"
	description "Draws actor many times in a circle, with configurable radius, start and stop angles."

	category :child_producer

	setting 'number', :integer, :range => 1..100, :default => 1..2, :summary => true
	setting 'radius', :float, :range => -100.0..100.0, :default => 0.0..1.0

	setting 'start_angle', :float, :default => 0.0..1.0
	setting 'stop_angle', :float, :default => 1.0..2.0

	setting 'distribution', :curve

	def render
		number.distribute_exclusive(start_angle..stop_angle) { |angle, index|
			angle = distribution.value(angle)
			with_roll(angle) {
				with_slide(radius) {
					yield :child_index => index, :total_children => number
				}
			}
		}
	end
end
