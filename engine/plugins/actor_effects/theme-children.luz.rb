class ActorEffectThemeChildren < ActorEffect
	title				"Theme Children"
	description "Uses chosen theme to style each successive child differently."

	categories :color, :child_consumer

	setting 'theme', :theme
	setting 'amount', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'offset', :integer, :range => -1000..1000, :default => 0..1

	def render
		return yield unless theme

		if amount == 1.0
			theme.using_style(child_index + offset) { yield }
		else
			theme.using_style_amount(child_index + offset, amount) {
				yield
			}
		end
	end
end
