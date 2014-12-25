module EngineProject
	include Callbacks

	callback :new_project

	def init_project
		@project = Project.new
	end

	def load_from_path(path)
		begin
			@project.load_from_path(path)
			new_project_notify
			true
		rescue Exception => e
			e.report('loading project')
			false
		end
	end

	pipe :save, :project
	pipe :save_to_path, :project
	pipe :project_changed!, :project, :method => :changed!
	pipe :project_changed?, :project, :method => :changed?

	def reinitialize_user_objects
		@project.each_user_object { |obj| safe { obj.after_load } }					# NOTE: use of user_object_try here would be silly, since we're about to set it non-crashy, but protection is still needed
		@project.each_user_object { |obj| safe { obj.resolve_settings } }
		@project.each_user_object { |obj| obj.crashy = false }
	end

	def project_pretick
		@project.effects.each(&:pretick!)		# { |effect| effect.pretick! }
	end

	def project_tick
		@project.effects.each(&:tick!)			# { |effect| effect.tick! }
	end
end
