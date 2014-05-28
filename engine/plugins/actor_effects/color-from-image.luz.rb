class ActorEffectColorFromImage < ActorEffect
	title				"Color from Image"
	description "Colors actor with a color picked from a chosen X,Y position within a chosen image."

	categories :color

	setting 'image', :image
	setting 'x', :float, :range => -100.0..100.0, :default => 0.0..1.0
	setting 'y', :float, :range => -100.0..100.0, :default => 0.0..1.0
	setting 'alpha', :float, :range => 0.0..1.0, :default => 1.0..0.0

	def render
		color = image.color_at(x % 1.0, y % 1.0)
		a = color.to_a
		a[3] = alpha
		with_color(a) {
			yield
		}
	end
end
