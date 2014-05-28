class ActorEffectTranslate < ActorEffect
	title				"Translate"
	description "Translates (moves) actor a chosen amount in its X and Y planes."

	category :transform

	setting 'x', :float, :default => 0.0..1.0
	setting 'y', :float, :default => 0.0..1.0

	def render
		with_translation(x, y) {
			yield
		}
	end
end
