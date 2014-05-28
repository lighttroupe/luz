class ProjectEffectReloadCode < ProjectEffect
	title				"Reload Code"
	description "Reloads the source code off disk.  For developers."

	setting 'reload', :event, :summary => 'on %'

	def tick
		$application.reload_code! if reload.on_this_frame?
	end
end
