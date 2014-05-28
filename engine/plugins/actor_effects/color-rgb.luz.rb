class ActorEffectColorRGB < ActorEffect
	title				"Color RGB"
	description "Colors actor."

	categories :color

	setting 'red', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'green', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'blue', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def render
		with_color([red, green, blue]) {
			yield
		}
	end
end
