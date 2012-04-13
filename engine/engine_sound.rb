module EngineSound
	include Callbacks

	def play_sound(file, options)
		@sound_manager.play(file, options) if init_sound?
	end

	def valid_sound_id?(sound_id)
		@sound_manager.valid_id?(sound_id) if init_sound?
	end

	def stop_sound_by_id(sound_id)
		@sound_manager.stop_by_id(sound_id) if init_sound?
	end

	def update_sound_volume(sound_id, volume)
		@sound_manager.update_volume(sound_id, volume) if init_sound?
	end

	def update_sound_pitch(sound_id, pitch)
		@sound_manager.update_pitch(sound_id, pitch) if init_sound?
	end

	def stop_sound_by_id(sound_id)
		@sound_manager.stop_by_id(sound_id) if init_sound?
	end

private

	def init_sound?
		if @sound_manager.nil?
			begin
				require 'sound_manager'
				@sound_manager = SoundManager.new
				on_frame_end { @sound_manager.tick! }
			rescue Exception => e
				e.report
				@sound_manager = false
			end
		end
		return (@sound_manager != false)
	end
end
