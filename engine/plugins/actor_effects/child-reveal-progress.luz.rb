class ActorEffectChildRevealProgress < ActorEffect
	title				"Child Reveal Progress"
	description "Hides all children and reveals them progressively, starting at child 1 and continuing on to the last child as a chosen progress reaches 1.0.\n\nFor children not yet revealed, further effects are not processed."

	categories :child_consumer

	# hint "useful for creating discrete volume meters"

	setting 'progress', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def render
		return if progress == 0.0

		yield if (child_index.to_f / total_children) <= progress
	end
end
