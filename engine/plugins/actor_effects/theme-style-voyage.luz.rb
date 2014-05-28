class ActorEffectThemeStyleVoyage < ActorEffect
	title				"Theme Voyage"
	description "Fades gradually between the styles of chosen theme."

	categories :color

	setting 'theme', :theme
	setting 'progress', :float, :default => 0.0..1.0

	def render
		return yield unless theme

		count = theme.effects.size		# TODO: clean this up
		return yield if count == 0

		# spot between 0.0 and eg. 7.0 for 7 actors
		spot = (count) * progress

		# the first actor
		index = spot.floor

		fade_amount = spot - index

		theme.using_style(index) {
			theme.using_style_amount((index+1) % count, fade_amount) {
				yield
			}
		}
	end
end
