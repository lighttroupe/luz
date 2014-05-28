class ActorEffectChildEnterStagger < ActorEffect
	title				"Child Enter Stagger"
	description "Causes children to enter consecutively, instead of concurently."

	categories :child_consumer

	hint "Use after an effect that creates children (eg. Line) and before one or more plugins that use Enter."

	def render
		# spot between 0.0 and eg. 7.0 for 6 actors
		spot = total_children * $env[:enter]

		# the active actor
		index = spot.floor

		if child_index == index
			with_env(:enter, spot - index) { yield }
		elsif child_index > index
			with_env(:enter, 0.0) { yield }
		else
			with_env(:enter, 1.0) { yield }
		end
	end
end
