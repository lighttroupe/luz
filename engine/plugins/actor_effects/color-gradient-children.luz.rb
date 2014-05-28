class ActorEffectColorGradientChildren < ActorEffect
	title				"Color Gradient Children"
	description "Colors successive children starting with the current color and ending with the chosen color."

	categories :color, :child_consumer

	setting 'color', :color, :default => [0.0, 0.0, 0.0, 1.0]

	def render
		child_index.distributed_among(total_children, 0.0..1.0) { |amount|
			with_color(current_color.fade_to(amount, color)) {
				yield
			}
		}
	end
end
