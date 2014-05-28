class ActorEffectActorAttach < ActorEffect
	title				'Actor Attach'
	description "Attach another actor above or below this one, at a chosen offset, angle, and distance."

	categories :special

	hint "This can be used to build robots, attaching arm to torso, etc."

	setting 'actor', :actor, :summary => true
	setting 'position', :select, :options => [[:below, 'Below'], [:above, 'Above']], :default => :above		# above = more likely to be visible

	setting 'offset_x', :float, :default => 0.0..1.0
	setting 'offset_y', :float, :default => 0.0..1.0

	setting 'angle', :float, :default => 0.0..1.0
	setting 'distance', :float, :default => 0.0..1.0

	setting 'scale', :float, :default => 1.0..2.0

	def render
		yield if position == :above

		actor.one { |a|
			with_translation(offset_x, offset_y) {
				with_roll(angle) {
					with_slide(distance) {
						with_scale(scale) {
							a.render!
						}
					}
				}
			}
		}

		yield if position == :below
	end
end
