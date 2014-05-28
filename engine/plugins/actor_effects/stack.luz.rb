class ActorEffectStack < ActorEffect
	title				"Stack"
	description "Draws actor many times, stacked in the Z dimension."

	categories :child_producer

	setting 'number', :integer, :range => 1..1000, :default => 1..2, :summary => true
	setting 'smallest', :float, :range => 0.0..9999.0, :default => 1.0..0.5
	setting 'height', :float, :default => 0.0..1.0

	def render
		for i in 0...number
			i.distributed_among(number, 1.0..smallest) { |amount|
				with_scale(amount) {
					with_translation(0,0,(i.to_f/number) * height) {
						yield :child_index => i, :total_children => number
					}
				}
			}
		end
	end
end
