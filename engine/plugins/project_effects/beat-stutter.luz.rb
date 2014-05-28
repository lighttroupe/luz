class ProjectEffectBeatStutter < ProjectEffect
	title				"Beat Stutter"
	description "Causes all effects that animate on the beat to appear to stutter."

	setting 'steps', :integer, :range => 0..64, :default => 1..2, :summary => '% steps per beat'

	def render
		step_index, step_progress = $env[:beat_scale].divmod(1.0 / steps)
		with_beat_shift(1.0 - step_progress) {
			yield
		}
	end
end
