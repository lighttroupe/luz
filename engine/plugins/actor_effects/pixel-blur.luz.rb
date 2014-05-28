class ActorEffectPixelBlur < ActorEffect
	title				"Pixel Blur"
	description "Averages several nearby pixels."

	categories :color

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'samples', :integer, :range => 1..8, :default => 1..4, :shader => true
	setting 'sample_distance', :float, :range => 0.0..1.0, :default => 0.004..1.0, :shader => true

	CODE = "
		vec4 accumulator = vec4(0.0,0.0,0.0,0.0);

		output_rgba *= texture2D(texture0, texture_st);

		for(int i=-samples ; i<=samples ; i++) {
			if(i != 0) {
				accumulator += texture2D(texture0, texture_st + vec2(float(i) * (sample_distance / 100.0), 0));
			}
		}

		for(int i=-samples ; i<=samples ; i++) {
			if(i != 0) {
				accumulator += texture2D(texture0, texture_st + vec2(0, float(i) * (sample_distance / 100.0)));
			}
		}

		accumulator /= float(samples * 4);

		output_rgba = mix(output_rgba, accumulator, amount);
	"

	def render
		return yield if amount == 0.0

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
