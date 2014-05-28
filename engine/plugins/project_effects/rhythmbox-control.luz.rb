class ProjectEffectRhythmboxControl < ProjectEffect
	title				"Rhythmbox Control"
	description "Remote control of the Rhythmbox music player."

	setting 'play', :event
	setting 'stop', :event

	setting 'next_track', :event
	setting 'previous_track', :event

	setting 'volume', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def tick
		`rhythmbox-client --play` if play.now?
		`rhythmbox-client --pause` if stop.now?

		`rhythmbox-client --next` if next_track.now?
		`rhythmbox-client --previous` if previous_track.now?

		if volume != @previous_volume
			`rhythmbox-client --set-volume #{volume}`
			@previous_volume = volume
		end
	end
end
