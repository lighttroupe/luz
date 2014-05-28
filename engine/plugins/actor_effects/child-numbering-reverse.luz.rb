class ActorEffectChildNumberingReverse < ActorEffect
	title				'Child Numbering Reverse'
	description 'Reverses the numbering of children (eg. 1,2,3 to 3,2,1), which may change how future effects treat the children.'

	categories :child_consumer

	def render
		yield :child_index =>	(total_children - child_index) - 1, :total_children => total_children
	end
end
