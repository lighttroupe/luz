class ActorEffectLineCentered < ActorEffect
	title				"Line Centered"
	description "Draws actor many times in a line, out from the center."

	category :child_producer

	setting 'number', :integer, :range => 1..100, :default => 1..2
	setting 'angle', :float, :range => -1.0..1.0, :default => 0.0..1.0
	setting 'distance', :float, :range => -100.0..100.0, :default => 1.0..2.0

	def render
		yield :total_children => number

		with_roll(angle) {
			for i in 1...number
				with_slide(distance * i) {
					with_roll(-angle) {
						yield :child_index => i, :total_children => number
					}
				}
				with_slide(distance * -i) {
					with_roll(-angle) {
						yield :child_index => i, :total_children => number
					}
				}
			end
		}
	end
end
