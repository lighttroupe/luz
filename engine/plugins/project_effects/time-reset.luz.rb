class ProjectEffectTimeReset < ProjectEffect
	title				"Time Reset"
	description "Resets Luz engine time to 0.0."

	setting 'reset', :event, :summary => 'on %'

	def render
		$engine.reset_time! if reset.now?
		yield
	end
end
