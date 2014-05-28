class ActorEffectHide < ActorEffect
	title				"Hide"
	description "Hides actor completely."

	category :transform

	hint "Useful with conditions."

	def render
		# doesn't yield
	end
end
