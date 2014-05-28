class ActorEffectColorHueRotate < ActorEffect
	title				"Color Hue Rotate"
	description ""

	categories :color

	setting 'amount', :float, :default => 0.0..1.0

	def render
		return yield if amount == 0.0

		c = current_color
		hsl = c.to_hsl
		hsl[0] = (hsl[0] + amount) % 1.0
		with_color(c.from_hsl(*hsl)) {
			yield
		}
	end
end
