class ActorEffectPixelWarp < ActorEffect
	title				"Pixel Warp"
	description "Squishes, warps, bends pixels in a variety of algorithmic ways."

	categories :color

	hint 'Multiple Pixel Warp plugins can be used simultaneously.'

	setting 'amount', :float, :default => 0.0..1.0, :shader => true
	setting 'frequency', :float, :default => 0.1..1.0, :shader => true
	setting 'method', :select, :default => :warp_horizontal, :options => [[:bulge, 'Bulge'], [:boxes, 'Boxes'], [:warp_horizontal, 'Warp Horizontal'], [:warp_vertical, 'Warp Vertical']], :summary => true

	WARP_BOXES = "
		texture_st.s += amount * 0.2 * (cos((texture_st.s-0.5) * mix(1.0, 500.0, frequency)));
		texture_st.t += amount * 0.2 * (cos((texture_st.t-0.5) * mix(1.0, 500.0, frequency)));
	"

	WARP_HORIZONTAL = "
		texture_st.x += amount * 0.2 * (cos((texture_st.y-0.5) * mix(1.0, 500.0, frequency)));
	"

	WARP_VERTICAL = "
		texture_st.y += amount * 0.2 * (cos((texture_st.x-0.5) * mix(1.0, 500.0, frequency)));
	"

	BULGE = "
		vec2 v = vec2(rand(texture_st.st - 0.5), rand(output_rgba.rg)) * rand(texture_st.ts - 0.5);
		texture_st.s += (cos(v.s) * amount);
		texture_st.t += (cos(v.t) * amount);
	"

	LOOKUP = {:boxes => WARP_BOXES, :bulge => BULGE, :warp_horizontal => WARP_HORIZONTAL, :warp_vertical => WARP_VERTICAL}
	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(LOOKUP[method], self) {
			yield
		}
	end
end
