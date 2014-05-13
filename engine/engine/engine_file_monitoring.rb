$inotify_present = optional_require 'rb-inotify'

module EngineFileMonitoring
	if $inotify_present
		puts 'Using iNotify for live reloading of changed images'

		$notifier ||= INotify::Notifier.new		# seems we only need one

		def with_watch(file_path)
			# Load file
			if yield
				# Add a watch, and when it fires, yield again
				$notifier.watch(file_path, :close_write) {
					puts "Reloading #{file_path} ..."
					yield
				}

				$notifier_io = [$notifier.to_io]
				$engine.on_frame_end { $notifier.process if IO.select($notifier_io, nil, nil, 0) } unless $notifier_callback_set
				$notifier_callback_set = true
			end
		end
	else
		def with_watch(file_path)		# stub
			yield
		end
	end
end
