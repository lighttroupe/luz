class ActorEffectThemeScrubChildren < ActorEffect
	title				"Theme Scrub Children"
	description "Smoothly blends chosen theme onto children with chosen offset."

	categories :color, :child_consumer

	setting 'theme', :theme
	setting 'amount', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'offset', :float, :range => -1000..1000, :default => 0..1

	def render
		return yield if (theme.nil? or theme.empty? or amount == 0.0)

		index, scrub = (child_index + offset).divmod(1.0)
		style_a, style_b = theme.style(index), theme.style(index+1)
		style_a.using_amount(amount) {
			style_b.using_amount(scrub * amount) {
				yield
			}
		}
	end
end
