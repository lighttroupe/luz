class ActorEffectPixelMask < ActorEffect
	title				"Pixel Mask"
	description ""

	categories :color

	setting 'method', :select, :default => :below, :options => [[:above, 'Above'], [:below, 'Below']], :summary => true

	setting 'red_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'green_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'blue_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'alpha_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true

	BELOW_CODE = "
		output_rgba *= texture2D(texture0, texture_st);
		if(output_rgba.a < alpha_cutoff || output_rgba.r < red_cutoff || output_rgba.g < green_cutoff || output_rgba.b < blue_cutoff) {
			output_rgba = vec4(0,0,0,0);
		}
	"
	ABOVE_CODE = "
		output_rgba *= texture2D(texture0, texture_st);
		if(output_rgba.a >= alpha_cutoff && output_rgba.r >= red_cutoff && output_rgba.g >= green_cutoff && output_rgba.b >= blue_cutoff) {
			output_rgba = vec4(0,0,0,0);
		}
	"
	# NOTE: >= overwise

	def render
		if method == :below
			return yield if (red_cutoff == 0.0 && green_cutoff == 0.0 && blue_cutoff == 0.0 && alpha_cutoff == 0.0)

			with_fragment_shader_snippet(BELOW_CODE, self) {
				yield
			}
		else
			return yield if (red_cutoff == 1.0 && green_cutoff == 1.0 && blue_cutoff == 1.0 && alpha_cutoff == 1.0)

			with_fragment_shader_snippet(ABOVE_CODE, self) {
				yield
			}
		end
	end
end
