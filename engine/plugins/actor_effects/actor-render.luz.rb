class ActorEffectActorRender < ActorEffect
	title				'Actor Render'
	description "Renders chosen actor once, immediate, live."

	categories :special

	hint "Useful for rendering on Canvas actors."

	setting 'actor', :actor, :summary => true

	def render
		#actor.one { |a| with_identity_transformation { a.render! } }
		actor.one { |a| parent_user_object.using { a.render! } }
		yield
	end
end
