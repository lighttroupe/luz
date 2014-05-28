class ProjectEffectDirectorVoyage < ProjectEffect
	title				"Director Voyage"
	description "Moves between selected directors using a percentage progress, showing at most two at a time."

	setting 'tag', :directors
	setting 'progress', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		tag.all { |directors|
			# integer number of directors
			count = directors.size

			# spot between 0.0 and eg. 7.0 for 6 directors
			spot = count * progress

			# the first director
			index = spot.floor

			director_lifetime = spot - index

			# New one comes in behind old one so draw it first
			with_enter_and_exit(director_lifetime, 0.0) {
				directors[index].render!
			} if index < count

			# "Old" one, eg. the first one once we're showing 2 (when index == 1)
			with_enter_and_exit(1.0, director_lifetime) {
				directors[index - 1].render!
			} if index > 0
		}
		yield
	end
end
