#
# Settings provides a YAML-backed key value store of application-wide settings
#
#require 'yaml'

class Settings
	def initialize
		@settings = {}
		@setting_callbacks = {}
	end

	def on_change(key, &proc)
		@setting_callbacks[key] ||= []
		@setting_callbacks[key] << proc
	end

	def load(path)
		@path = path		# store for save, even if file doesn't exist
		File.open(path, 'r') { |file|
			load_settings_from_file(file)
			#puts "Loaded settings from #{path}..."
		} rescue Errno::ENOENT
		self
	end

	def save(path=nil)
		path ||= @path
		begin
			File.open(path, 'w') { |file|
				save_settings_to_file(file)
				@path = path
				#puts "Saved settings to #{path}..."
			}
		rescue => e
			puts "error saving"
			p e.report_format
		end
		self
	end

	def [](key)
		@settings[key]
	end

	def []=(key, value)
		#puts "$settings#{key} = #{value}"
		return if (@settings[key] && @settings[key] == value)
		@settings[key] = value
		@setting_callbacks[key].each { |proc| proc.call(value) } if @setting_callbacks[key]
	end

private

	def load_settings_from_file(file)
		settings = YAML.load(file)
		@settings = settings if settings.is_a? Hash
	end

	def save_settings_to_file(file)
		ZAML.dump(@settings, file)
	end
end
