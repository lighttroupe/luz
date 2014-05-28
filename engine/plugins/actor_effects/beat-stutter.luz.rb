class ActorEffectBeatStutter < ActorEffect
	title				'Beat Stutter'
	description "Causes future effects that animate on the beat to appear to stutter."

	categories :special

	setting 'steps', :integer, :range => 0..64, :default => 1..2

	def render
		step_index, step_progress = $env[:beat_scale].divmod(1.0 / steps)
		with_beat_shift(-step_progress) {
			yield
		}
	end
end
