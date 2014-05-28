class ActorEffectRGBSplit < ActorEffect
	title				"RGB Split"
	description "Splits one actor into three, filtered by Red, Green, Blue respectively."

	hint "Can be effective with Draw Method Brighten."

	categories :color, :child_producer

	setting 'distance', :float, :default => 0.0..1.0
	setting 'angle', :float, :default => 0.0..1.0

	def render
		return yield if distance == 0.0

		with_angle_slide(angle, -distance) {
			with_color([1.0, 0.0, 0.0]) {
				yield :child_index => 0, :total_children => 3
			}
		}
		with_color([0.0, 1.0, 0.0]) {
			yield :child_index => 1, :total_children => 3
		}
		with_angle_slide(angle, distance) {
			with_color([0.0, 0.0, 1.0]) {
				yield :child_index => 2, :total_children => 3
			}
		}
	end
end
