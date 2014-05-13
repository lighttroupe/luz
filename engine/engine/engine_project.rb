module EngineProject
	def init_engine_project
		@project = Project.new
	end

	def load_from_path(path)
		@project.load_from_path(path)
		new_project_notify
	end

	pipe :save, :project
	pipe :save_to_path, :project
	pipe :project_changed!, :project, :method => :changed!
	pipe :project_changed?, :project, :method => :changed?

	def reinitialize_user_objects
		@project.each_user_object { |obj| safe { obj.after_load } }
		@project.each_user_object { |obj| safe { obj.resolve_settings } }
		@project.each_user_object { |obj| obj.crashy = false }
	end

	def notify_of_new_user_object_classes
		# call the notify callback for just new ones
		@num_known_user_object_classes.upto(UserObject.inherited_classes.size - 1) { |index|
			new_user_object_class_notify(UserObject.inherited_classes[index])
		}
		@num_known_user_object_classes = UserObject.inherited_classes.size
	end
end
