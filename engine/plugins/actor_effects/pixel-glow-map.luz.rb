class ActorEffectPixelGlowMap < ActorEffect
	virtual		# deprecated, not useful

	title				"Pixel Glow Map"
	description "Uses chosen image to add to (or subtact from) actor's pixel values."

	categories :color

	setting 'glow_map', :image, :shader => true
	setting 'amount', :float, :range => -10.0..10.0, :default => 0.0..2.0, :shader => true
	setting 'offset_x', :float, :range => -1.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'offset_y', :float, :range => -1.0..1.0, :default => 0.0..1.0, :shader => true

	CODE = "
		vec4 glow_rgba = texture2D(glow_map, texture_st + vec2(-offset_x, offset_y));

		output_rgba.r += (glow_rgba.r * glow_rgba.a * amount);
		output_rgba.g += (glow_rgba.g * glow_rgba.a * amount);
		output_rgba.b += (glow_rgba.b * glow_rgba.a * amount);
	"

	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
