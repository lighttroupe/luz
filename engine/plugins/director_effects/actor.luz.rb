class DirectorEffectActor < DirectorEffect
	virtual

	title				"Actor"
	description "Puts a single actor on stage."

	setting 'actor', :actor, :summary => true

	def render
		actor.render!
		yield
	end
end
