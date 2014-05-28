class ActorEffectSaturate < ActorEffect
	title				"Saturate"
	description "Over-saturate or under-saturate image. Amounts above 1.0 multiply color channels, while amounts below 1.0 move colors towards an average of the RGB components."

	categories :color

	setting 'amount', :float, :range => 0.0..100.0, :default => 1.0..2.0, :shader => true

	def render
		if amount < 1.0
			code = "
				output_rgba *= texture2D(texture0, texture_st);

				float average_intensity = (output_rgba.r + output_rgba.g + output_rgba.b) / 3.0;

				float desaturation = (1.0 - amount);

				// move each color channel towards average color
				output_rgba.r = mix(output_rgba.r, average_intensity, desaturation);
				output_rgba.g = mix(output_rgba.g, average_intensity, desaturation);
				output_rgba.b = mix(output_rgba.b, average_intensity, desaturation);
			"
		elsif amount > 1.0
			code = "
				output_rgba *= amount;
			"
		end

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
