class ProjectEffectStopPerformer < ProjectEffect
	title				"Stop Performer"
	description "Quits fullscreen performance mode on a chosen event."

	setting 'event', :event, :summary => 'on %'

	def tick
		$application.finished! if event.now?
	end
end
