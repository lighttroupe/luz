class ActorEffectRepeat < ActorEffect
	title				"Repeat"
	description	"Draws actor multiple times."

	category :child_producer

	setting 'number', :integer, :range => 1..100, :default => 1..2, :summary => true

	def render
		for i in 0...number
			yield :child_index => i, :total_children => number
		end
	end
end
