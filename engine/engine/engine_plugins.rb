module EnginePlugins
	def load_plugins(directory=nil)
		count = load_directory(Engine::PLUGIN_DIRECTORY_PATH, '*.luz.rb')
		notify_of_new_user_object_classes
		return count
	end
end
