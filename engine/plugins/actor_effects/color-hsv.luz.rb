class ActorEffectColorHSV < ActorEffect
	title				"Color HSV"
	description "Colors actor."

	categories :color

	setting 'hue', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'saturation', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'value', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def render
		@color ||= Color.new
		@color.from_hsl(hue, saturation, value)
		with_color(@color) {
			yield
		}
	end
end
