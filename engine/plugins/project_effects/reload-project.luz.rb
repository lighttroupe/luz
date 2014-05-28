class ProjectEffectReloadProject < ProjectEffect
	title				"Reload Project"
	description "Reloads the Luz project off disk."

	setting 'reload', :event, :summary => 'on %'

	def render
		if reload.on_this_frame?
			puts 'Reloading project!'
			$engine.load_from_path($engine.project.path)
			# does not yield -- no point in continuing this frame
		else
			yield		# fullscreen normal case
		end
	end
end
