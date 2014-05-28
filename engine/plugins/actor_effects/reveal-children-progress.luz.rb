class ActorEffectRevealChildrenProgress < ActorEffect
	virtual		# deprecated

	title				"Reveal Children Progress"
	description ""

	setting 'progress', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		return if progress == 0.0

		yield if (child_index.to_f / total_children) <= progress
	end
end
