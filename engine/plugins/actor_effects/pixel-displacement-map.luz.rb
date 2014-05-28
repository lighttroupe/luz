class ActorEffectPixelDisplacementMap < ActorEffect
	title				"Pixel Displacement Map"
	description "Uses chosen image to offset actor's pixels."

	categories :color

	setting 'displacement_map', :image, :shader => true
	setting 'amount', :float, :range => -10.0..10.0, :default => 0.0..2.0, :shader => true

	CODE = "
		vec4 displacement_rgba = texture2D(displacement_map, texture_st);

		texture_st.s += (displacement_rgba.r + displacement_rgba.g - 1.0) * (amount / 10.0);
		texture_st.t += (displacement_rgba.b + displacement_rgba.a - 1.0) * (amount / 10.0);
	"

	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
