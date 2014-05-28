class ActorEffectChildExitStagger < ActorEffect
	title				"Child Exit Stagger"
	description "Causes children to exit consecutively, instead of concurently."

	categories :child_consumer

	hint "Use after an effect that creates children (eg. Line) and before one or more plugins that use Exit."

	def render
		# spot between 0.0 and eg. 7.0 for 6 actors
		spot = total_children * $env[:exit]

		# the active actor
		index = spot.floor

		if child_index == index
			with_env(:exit, spot - index) { yield }
		elsif child_index > index
			with_env(:exit, 0.0) { yield }
		else
			with_env(:exit, 1.0) { yield }
		end
	end
end
