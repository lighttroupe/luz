class ActorEffectChildNumberingRotate < ActorEffect
	title				"Child Numbering Rotate"
	description "Rotate the numbering of children (eg. 1,2,3,4 to 2,3,4,1), which may change how future effects treat the children."

	categories :child_consumer

	setting 'number', :integer, :range => 0..100, :default => 1..2

	def render
		yield :child_index =>	(child_index + number) % total_children, :total_children => total_children
	end
end
