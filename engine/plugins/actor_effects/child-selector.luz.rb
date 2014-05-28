class ActorEffectChildSelector < ActorEffect
	title				"Child Selector"
	description "Forcibly sets the internal 'child number' based on the activation count of a chosen event."

	categories :child_consumer

	hint "Future effects can be filtered based on the child number."

	setting 'event', :event
	setting 'count', :integer, :range => 1..100, :default => 2..3

	def render
		# This is a real hack of the child numbering system. :) -Ian
		yield :child_index => (event_setting.count % count), :total_children => count
	end
end
