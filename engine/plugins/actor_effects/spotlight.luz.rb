class ActorEffectSpotlight < ActorEffect
	title				'Spotlight'
	description 'A spotlight is a combination of the brightening draw mode, alpha control, a stack, and scaling.'

	categories :child_producer

	setting 'number', :integer, :range => 1..1000, :default => 1..2
	setting 'roll', :float, :range => -1000.0..1000.0, :default => 0.0..1.0
	setting 'smallest', :float, :range => 0.0..1000.0, :default => 1.0..1.0
	setting 'height', :float, :range => 0.0..1000.0, :default => 0.5..1.0
	setting 'alpha', :float, :range => 0.0..1.0, :default => 0.5..1.0

	def render
		with_multiplied_alpha(alpha) {
			with_pixel_combine_function(:brighten) {
				for i in 0...number
					i.distributed_among(number, 1.0..smallest) { |scale_amount|
						with_scale(scale_amount) {
							i.distributed_among(number, 0.0..roll) { |roll_amount|
								with_roll(roll_amount) {
									with_translation(0,0,(i.to_f/number) * height) {
										yield :child_index => i, :total_children => number
									}
								}
							}
						}
					}
				end
			}
		}
	end
end
