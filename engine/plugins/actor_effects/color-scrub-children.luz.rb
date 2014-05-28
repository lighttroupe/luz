class ActorEffectColorScrubChildren < ActorEffect
	title				"Color Scrub Children"
	description ""

	categories :color, :child_consumer

	setting 'color', :color
	setting 'progress', :float, :range => -1.0..2.0, :default => 0.0..1.0
	setting 'amount', :float,  :range => 0.0..1.0, :default => 1.0..1.0
	setting 'spread', :float, :range => 0.0..1.0, :default => 0.5..1.0

	def render
		child_progress = ((child_number-1).to_f / (total_children-1).to_f)
		delta = (child_progress - progress).abs
		# the bigger the delta, the less color application will occur
		# delta is 0.0..1.0
		delta /= (spread * 2.0)
		fade_amount = (amount - delta).clamp(0.0, 1.0)
		with_color(current_color.fade_to(fade_amount, color)) {
			yield
		}
	end
end
