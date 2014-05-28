class ProjectEffectTimeBump < ProjectEffect
	title				'Time Bump'
	description "Causes all time-based animations to jump forward or backward in time."

	setting 'amount', :timespan

	setting 'bump_forward', :event
	setting 'bump_backward', :event

	def pretick
		$engine.add_to_engine_time(amount.to_seconds) if bump_forward.on_this_frame?
		$engine.add_to_engine_time(-amount.to_seconds) if bump_backward.on_this_frame?
	end
end
