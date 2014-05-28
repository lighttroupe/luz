class ProjectEffectStopPerformer < ProjectEffect
	title				"Stop Performer"
	description "Quits fullscreen performance mode on a chosen event."

	hint "Also capable of quiting the Video Renderer."

	setting 'event', :event, :summary => 'on %'

	def tick
		$application.finished! if event.now?
	end
end
