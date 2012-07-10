class DirectorEffectSound < DirectorEffect
	title				"Sound"
	description "Plays a sound with chosen position, volume and pitch."

	setting 'sound_file', :string, :summary => true
	setting 'play', :event, :summary => true

	setting 'volume', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'pitch', :float, :range => 0.0..100.0, :default => 1.0..1.0

	def render
		if $sound and play.on_this_frame?
			$sound.play(sound_file, :volume => volume, :pitch => pitch)		#, :at => Position.new(position_x, position_y, position_z))
		end
		yield
	end
end
