require 'actor_effect'

class ActorEffectCanvas < ActorEffect
	virtual

	def render
		parent_user_object.with_canvas { |canvas| paint(canvas) }		# TODO: Should this be moved to a 'Painting' module, much like 'Drawing'?
		yield		# continue effect tree
	end
end
