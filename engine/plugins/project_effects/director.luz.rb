class ProjectEffectDirector < ProjectEffect
	title				"Director"
	description "Draws chosen director with manual enter/exit progress control."

	setting 'director', :director, :summary => true
	setting 'progress', :float, :range => 0.0..1.0, :default => 0.5..1.0

	def render
		with_enter_exit_progress(progress) {
			director.render
		}
		yield
	end
end
