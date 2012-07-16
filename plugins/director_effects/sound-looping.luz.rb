class DirectorEffectSoundLooping < DirectorEffect
	title				"Sound Looping"
	description "Plays a looping sound with chosen volume and pitch."

	setting 'sound_file', :string, :summary => true

	setting 'volume', :float, :range => 0.0..10.0, :default => 1.0..1.0
	setting 'pitch', :float, :range => 0.0..100.0, :default => 1.0..1.0

	setting 'fade_time', :timespan, :default => [1, :seconds]

	setting 'restart', :event

	def deep_clone(*args)
		@sound_id = nil
		super
	end

	def tick
		return unless $sound

		if sound_file and sound_file != ''
			# our id may have been terminated if this Director was abruptly abandoned while playing
			@sound_id = nil unless $sound.valid_id?(@sound_id)

			if (restart.on_this_frame? || @sound_id.nil? || @playing_sound != sound_file)
				$sound.stop_by_id(@sound_id) if @sound_id
				@sound_id = $sound.play(@playing_sound=sound_file, :looping => true, :volume => volume, :pitch => pitch, :fade_time => fade_time.to_seconds)
			end

			return unless @sound_id
			$sound.update_volume(@sound_id, volume)
			$sound.update_pitch(@sound_id, pitch)
		else
			$sound.stop_by_id(@sound_id) if @sound_id
		end
	end
end
