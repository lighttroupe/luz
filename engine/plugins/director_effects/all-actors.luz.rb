class DirectorEffectAllActors < DirectorEffect
	virtual

	title				'All Actors'
	description "Puts all actors on stage, in their natural order back-to-front."

	hint "This may be sufficient for basic projects."

	def render
		$engine.project.actors.each { |a| a.render! }
		yield
	end
end
