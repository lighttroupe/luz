class ActorEffectCrashyRender < ActorEffect
	virtual		# hidden

	title				"Crashy Render"
	description "[FOR TESTING ONLY] Causes an exception in render method"

	def render
		1/0
	end
end
