class ActorEffectInvert < ActorEffect
	title				"Invert"
	description "Inverts pixel color components."

	category :color

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true

	def render
		return yield if amount == 0.0

		code = "
			output_rgba *= texture2D(texture0, texture_st);
			output_rgba.r = mix(output_rgba.r, 1.0 - output_rgba.r, amount);
			output_rgba.g = mix(output_rgba.g, 1.0 - output_rgba.g, amount);
			output_rgba.b = mix(output_rgba.b, 1.0 - output_rgba.b, amount);
		"

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
