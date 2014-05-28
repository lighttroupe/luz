class ActorEffectPixelColorReduce < ActorEffect
	title				"Pixel Color Reduce"
	description ""

	categories :color

	setting 'segments', :integer, :range => 1..1000, :default => 100..1000, :shader => true

	def render
		code = "
			output_rgba *= texture2D(texture0, texture_st);

			output_rgba.r = floor(output_rgba.r * float(segments)); // / segments; 
			output_rgba.g = floor(output_rgba.g * float(segments)); // / segments; 
			output_rgba.b = floor(output_rgba.b * float(segments)); // / segments;
			
			output_rgba.rgb /= float(segments); 
		"

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
