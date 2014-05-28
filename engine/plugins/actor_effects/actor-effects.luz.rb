class ActorEffectActorEffects < ActorEffect
	title				'Actor Effects'
	description "Borrows all effects from chosen actor, running them as if they were inserted in place of this plugin in the effects list."

	categories :special

	setting 'actor', :actor, :summary => true

	def render
		actor.one { |a|
			a.render_recursive {
				yield
			}
			return
		}
		yield
	end
end
