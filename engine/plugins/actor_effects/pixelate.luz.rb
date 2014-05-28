class ActorEffectPixelate < ActorEffect
	title				"Pixelate"
	description "Draws image at a lower resolution."

	categories :color

	setting 'segments_x', :integer, :range => 1..1000, :default => 100..1000, :shader => true
	setting 'segments_y', :integer, :range => 1..1000, :default => 100..1000, :shader => true

	def render
		code = "
			float x = floor(texture_st.s * float(segments_x));
			float y = floor(texture_st.t * float(segments_y));

			texture_st.s = (x * (1.0 / float(segments_x)));
			texture_st.t = (y * (1.0 / float(segments_y)));
		"

		with_fragment_shader_snippet(code, self) {
			yield
		}
	end
end
