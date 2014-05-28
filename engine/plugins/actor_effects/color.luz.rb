class ActorEffectColor < ActorEffect
	title				"Color"
	description "Colors actor."

	category :color

	setting 'color', :color, :default => [1.0, 1.0, 1.0, 1.0]
	setting 'amount', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def render
		return yield if amount == 0.0

		if amount == 1.0
			with_color(color) {
				yield
			}
		else
			with_color(current_color.fade_to(amount, color)) {
				yield
			}
		end
	end
end
