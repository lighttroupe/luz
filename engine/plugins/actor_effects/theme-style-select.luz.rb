class ActorEffectThemeStyleSelect < ActorEffect
	title				"Theme Style Select"
	description ""

	categories :color

	setting 'theme', :theme

	setting 'forwards', :event, :summary => '% forward'
	setting 'backwards', :event, :summary => '% backward'

	def render
		return yield unless theme

		theme.using_style(forwards.count - backwards.count) { yield }
	end
end
