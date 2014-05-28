class ActorEffectColorInvert < ActorEffect
	title				"Color Invert"
	description "Inverts set color."

	categories :color

	setting 'amount', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def render
		return yield if amount == 0.0

		c = current_color
		@a ||= []
		@a[0] = amount.scale(c.red, 1.0-c.red)
		@a[1] = amount.scale(c.green, 1.0-c.green)
		@a[2] = amount.scale(c.blue, 1.0-c.blue)
		@a[3] = 1.0
		with_color(@a) {
			yield
		}
	end
end
