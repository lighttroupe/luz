class ActorEffectScale < ActorEffect
	title				'Scale'
	description 'Scales actor equally in its X and Y dimensions.'

	category :transform

	setting 'amount', :float, :default => 1.0..2.0

	def render
		with_scale(amount, amount) {
			yield
		}
	end
end
