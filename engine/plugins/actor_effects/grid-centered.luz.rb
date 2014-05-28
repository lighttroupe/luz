class ActorEffectGridCentered < ActorEffect
	title       "Grid Centered"
	description "Draws actor many times in a grid pattern, out from the center."

	category :child_producer

	setting 'offset', :float, :range => -100.0..100.0, :default => 1.0..2.0
	setting 'number_x', :integer, :range => 0..100, :default => 0..2
	setting 'number_y', :integer, :range => 0..100, :default => 0..2

	def render
		total_children = [number_x.abs + 1, number_y.abs + 1].max

		for y in (-number_y..number_y)
			for x in (-number_x..number_x)
				with_translation(x * offset, y * offset) {
					yield :child_index => [x.abs, y.abs].max, :total_children => total_children
				}
			end
		end
	end
end
