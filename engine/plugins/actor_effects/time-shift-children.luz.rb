class ActorEffectTimeShiftChildren < ActorEffect
	title				'Time Shift Children'
	description "Causes children to render as if each successive child were more in the past."

	hint "Place this after an effect that creates children, and before one or more effects that animate on time."

	categories :special, :child_consumer

	setting 'time_per_child', :timespan
	setting 'amount', :float, :default => 0.0..1.0

	def render
		with_time_shift(amount * -(time_per_child.to_seconds) * child_index) {
			yield
		}
	end
end
