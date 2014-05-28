#Class.new(ActorEffect).class_eval begin

class ActorEffectTranslateZ < ActorEffect
	title				"Translate Z"
	description "Translates (moves) actor a chosen amount on its Z axis."

	category :transform

	setting 'amount', :float, :range => -100.0..100.0, :default => 0.0..1.0

	def render
		with_translation(0.0, 0.0, amount) {
			yield
		}
	end
end

