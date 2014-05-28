class ActorEffectScanLinesVertical < ActorEffect
	title				"Scan Lines Vertical"
	description "Creates vertical scanlines in images, with optional fading and vertical translation."

	categories :color

	setting 'size', :float, :range => 0.0..1.0, :default => 0.05..1.0, :shader => true
	setting 'fade_one', :float, :range => 0.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'offset_one', :float, :range => -1.0..1.0, :default => 0.0..1.0, :shader => true
	setting 'fade_two', :float, :range => 0.0..1.0, :default => 0.5..1.0, :shader => true
	setting 'offset_two', :float, :range => -1.0..1.0, :default => 0.0..1.0, :shader => true

	CODE = "
		if (mod(pixel_xyzw.x, size) >= (size / 2.0)) {
			texture_st.t -= (offset_one);
			output_rgba.a *= (1.0-fade_one);
		} else {
			texture_st.t -= (offset_two);
			output_rgba.a *= (1.0-fade_two);
		}
	"

	def render
		with_fragment_shader_snippet(CODE, self) {
			yield
		}
	end
end
