class ActorEffectPixelMask < ActorEffect
	title				"Pixel Mask"
	description ""

	categories :color

	setting 'red_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'green_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'blue_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'alpha_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true

	CODE = "
		output_rgba *= texture2D(texture0, texture_st);
		if(output_rgba.a < alpha_cutoff || output_rgba.r < red_cutoff || output_rgba.g < green_cutoff || output_rgba.b < blue_cutoff) {
			output_rgba = vec4(0,0,0,0);
		}
	"

	def render
		return yield if (red_cutoff == 0.0 and green_cutoff == 0.0 and blue_cutoff == 0.0 and alpha_cutoff == 0.0)

		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
