class ActorEffectPixelStorm < ActorEffect
	title				"Pixel Storm"
	description "Displace pixels in random directions."

	categories :color

	setting 'amount', :float, :default => 0.0..1.0, :shader => true

	CODE = "
		texture_st.s += ((0.5 - rand(texture_st.st)) * amount);
		texture_st.t += ((0.5 - rand(texture_st.ts)) * amount);
	"

	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
