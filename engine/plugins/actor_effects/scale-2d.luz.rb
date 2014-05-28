class ActorEffectScale2D < ActorEffect
	title				'Scale 2D'
	description 'Scales actor in its X and Y dimensions.'

	category :transform

	setting 'amount_x', :float, :default => 1.0..2.0
	setting 'amount_y', :float, :default => 1.0..2.0

	setting 'pivot_offset_x', :float, :default => 0.0..0.5
	setting 'pivot_offset_y', :float, :default => 0.0..0.5

	def render
		with_translation(pivot_offset_x * (1.0 - amount_x), pivot_offset_y * (1.0 - amount_y)) {
			with_scale(amount_x, amount_y) {
				yield
			}
		}
	end
end
