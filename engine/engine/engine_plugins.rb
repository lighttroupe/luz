module EnginePlugins
	def load_plugins(directory=nil)
		load_directory(Engine::PLUGIN_DIRECTORY_PATH, '*.luz.rb')		# returns file count
	end
end
