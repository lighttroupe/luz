class ActorEffectGrid < ActorEffect
	title				"Grid"
	description	"Draws actor many times in a grid pattern, left to right, top to bottom."

	category :child_producer

	setting 'offset', :float, :range => -100.0..100.0, :default => 1.0..2.0
	setting 'number_x', :integer, :range => 0..100, :default => 1..2, :summary => true
	setting 'number_y', :integer, :range => 0..100, :default => 1..2, :summary => true

	def render
		total_children = number_x * number_y

		with_translation(-(number_x * offset * 0.5) + 0.5 + (offset - 1.0) / 2.0,  -(number_y * offset * 0.5) + 0.5 + (offset - 1.0) / 2.0) {
			for y in (0...number_y)
				for x in (0...number_x)
					with_translation((x * offset), (((number_y - y) - 1) * offset)) {
						yield :child_index => x + (y * number_x), :total_children => total_children
					}
				end
			end
		}
	end
end
