class ActorEffectRadialBlurRepeater < ActorEffect
	title				"Radial Blur Repeater"
	description "A blur effect created by repeating the actor multiple times, each larger than the last."

	categories :color

	setting 'amount', :float, :range => 0.0..100.0, :default => 0.0..0.5
	setting 'number', :integer, :range => 1..1000, :default => 0..2

	def render
		return yield if number == 1 or amount == 0.0

		with_pixel_combine_function(:brighten) {
			with_multiplied_alpha(1.0 / number) {
				number.times { |n|
					with_scale(1.0 + (amount * n)) {
						yield :child_index => n, :total_children => number
					}
				}
			}
		}
	end
end
