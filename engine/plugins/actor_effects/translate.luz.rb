class ActorEffectTranslate < ActorEffect
	title				"Translate"
	description "Moves actor a chosen amount in X, Y, Z."

	category :transform

	setting 'x', :float, :default => 0.0..1.0
	setting 'y', :float, :default => 0.0..1.0
	setting 'z', :float, :default => 0.0..1.0

	def render
		with_translation(x, y, z) {
			yield
		}
	end
end
