class ActorEffectBeatShiftChildren < ActorEffect
	title				"Beat Shift Children"
	description "Causes each successive child to render as if it were more beats in the past."

	categories :special, :child_consumer

	hint				"Place this after an effect that creates children, and before one or more effects that animate on the beat."

	setting 'beats_per_child', :integer, :range => 1..100, :default => 1..2
	setting 'amount', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def render
		with_beat_shift(-child_index * beats_per_child * amount) {
			yield
		}
	end
end
