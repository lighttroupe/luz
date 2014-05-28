class ActorEffectStipple < ActorEffect
	title				"Stipple"
	description "Represent image using a grid of dots."

	categories :color

	setting 'segments', :integer, :range => 1..1000, :default => 100..10000, :shader => true
	setting 'size', :float, :range => 0.0..1.0, :default => 1.0..1.0, :shader => true

	CODE = "
		float floor_x = floor(texture_st.x * float(segments));
		float floor_y = floor(texture_st.y * float(segments));

		float square_side_length = (1.0 / float(segments));
		float center_x = (floor_x * square_side_length) + (square_side_length * 0.5);
		float center_y = (floor_y * square_side_length) + (square_side_length * 0.5);

		// from center
		float delta_x = (texture_st.x - center_x);
		float delta_y = (texture_st.y - center_y);

		float radius_squared = (square_side_length * 0.707 * size);		// sqrt(0.5^2 + 0.5^2) = 0.707 (stipple circles touches square corner at size == 1.0)
		radius_squared = radius_squared * radius_squared;

		if(((delta_x*delta_x) + (delta_y*delta_y)) < radius_squared) {
			texture_st.x = center_x;
			texture_st.y = center_y;
		} else {
			output_rgba = vec4(0.0,0.0,0.0,0.0);
		}
	"

	def render
		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
