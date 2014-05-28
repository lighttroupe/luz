class DirectorEffectActorVoyage < DirectorEffect
	virtual

	title				"Actor Voyage"
	description "Moves between selected actors using a percentage progress, showing at most two at a time."

	setting 'tag', :actors, :summary => 'tagged %'
	setting 'progress', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		tag.all { |actors|
			# integer number of actors
			count = actors.size

			# spot between 0.0 and eg. 7.0 for 6 actors
			spot = count * progress

			# the first actor
			index = spot.floor

			actor_lifetime = spot - index

			# New one comes in behind old one so draw it first
			with_enter_and_exit(actor_lifetime, 0.0) {
				actors[index].render!
			} if index < count

			# "Old" one, eg. the first one once we're showing 2 (when index == 1)
			with_enter_and_exit(1.0, actor_lifetime) {
				actors[index - 1].render!
			} if index > 0
		}
		yield
	end
end
