class DirectorEffectAllActorsWithTag < DirectorEffect
	virtual

	title				"All Actors with Tag"
	description "Puts all actors tagged with chosen tag on stage, in their natural order back-to-front."

	setting 'tag', :actors, :summary => 'tagged %'

	def render
		tag.each_with_index { |a, index| a.render! }
		yield
	end
end
