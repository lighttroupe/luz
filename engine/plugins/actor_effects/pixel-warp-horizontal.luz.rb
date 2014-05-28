class ActorEffectPixelWarpHorizontal < ActorEffect
	title				"Pixel Warp Horizontal"
	description "Offsets pixels in a wavy way."

	categories :color

	setting 'amount', :float, :default => 0.0..1.0, :shader => true
	setting 'frequency', :float, :default => 0.1..1.0, :shader => true

	CODE = "
		texture_st.s += amount * 0.2 * (cos(texture_st.t * mix(1, 500, frequency)));
		texture_st.t += amount * 0.2 * (cos(texture_st.s * mix(1, 500, frequency)));
	"

	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
