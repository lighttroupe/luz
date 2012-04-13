class DirectorEffectSoundLooping < DirectorEffect
	title				"Sound Looping"
	description "Plays a looping sound with chosen volume and pitch."

	setting 'sound_file', :string, :summary => true

	setting 'volume', :float, :range => 0.0..10.0, :default => 1.0..1.0
	setting 'pitch', :float, :range => 0.0..100.0, :default => 1.0..1.0

#	Position = Struct.new(:x,:y,:z)

	def tick
		if sound_file and sound_file != ''
			# our id may have been terminated if this Director was abruptly abandoned while playing
			@sound_id = nil unless $engine.valid_sound_id?(@sound_id)

			if (@sound_id.nil? or @playing_sound != sound_file)
				$engine.stop_sound_by_id(@sound_id) if @sound_id
				@sound_id = $engine.play_sound(@playing_sound=sound_file, :looping => true, :volume => volume, :pitch => pitch, :fade_in => true)
			end

			return unless @sound_id
			$engine.update_sound_volume(@sound_id, volume)
			$engine.update_sound_pitch(@sound_id, pitch)
		else
			$engine.stop_sound_by_id(@sound_id) if @sound_id
		end
	end
end
