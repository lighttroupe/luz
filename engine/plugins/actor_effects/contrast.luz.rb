class ActorEffectContrast < ActorEffect
	title				"Contrast"
	description "Increase or decrease the contrast of the image. Amounts over 1.0 make colors more extreme, while amounts under 1.0 move colors towards gray."

	categories :color

	setting 'amount', :float, :range => 0.0..2.0, :default => 1.0..2.0, :shader => true

	def render
		return yield if amount == 1.0

		if amount < 1.0
			code = "
				output_rgba *= texture2D(texture0, texture_st);

				float decontrast = (1.0 - amount);

				// move each color channel towards a pure gray
				output_rgba.r = mix(output_rgba.r, 0.5, decontrast);
				output_rgba.g = mix(output_rgba.g, 0.5, decontrast);
				output_rgba.b = mix(output_rgba.b, 0.5, decontrast);
			"
		elsif amount > 1.0
			code = "
				output_rgba *= texture2D(texture0, texture_st);

				// move each color channel towards average color
				if(output_rgba.r < 0.5) {
					output_rgba.r *= mix(output_rgba.r, 0.0, amount-1.0);
				} else {
					output_rgba.r = mix(output_rgba.r, 1.0, amount-1.0);
				}
				if(output_rgba.g < 0.5) {
					output_rgba.g = mix(output_rgba.g, 0.0, amount-1.0);
				} else {
					output_rgba.g = mix(output_rgba.g, 1.0, amount-1.0);
				}
				if(output_rgba.b < 0.5) {
					output_rgba.b = mix(output_rgba.b, 0.0, amount-1.0);
				} else {
					output_rgba.b = mix(output_rgba.b, 1.0, amount-1.0);
				}
			"
		end

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
