class DirectorEffectDirectorEffects < DirectorEffect
	virtual

	title				'Director Effects'
	description "Borrows all effects from chosen director, running them as if they were inserted in place of this plugin in the effects list."

	setting 'director', :director

	def render
		director.one { |d|
			d.render_scene_recursive {
				yield
			}
			return
		}
		yield
	end
end
