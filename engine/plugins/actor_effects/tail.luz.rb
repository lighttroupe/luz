class ActorEffectTail < ActorEffect
#	virtual		# deprecated

	title				"Tail"
	description ''

	category :child_producer

	setting 'number', :integer, :range => 1..100, :default => 1..2
	setting 'beats', :integer, :range => 1..100, :default => 1..2
	setting 'length', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		number.distribute(-length..0.0) { |beat_shift, index|
			with_beat_shift(beats * beat_shift) {
				yield :child_index => (number - index) - 1, :total_children => number
			}
		}
	end
end
