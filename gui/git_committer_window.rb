require 'glade_window'

#require 'fileutils'

class GitCommitterWindow < GladeWindow
	def initialize(path)
		super('git_committer_window')
		@path = path
	end

	def on_delete_event
		Gtk.main_quit		# quit app when main window is closed
	end

#	def on_play_button_clicked
#	end

#	def on_file_chosen
#	end

	def send_progress(progress)
		# create OSC message
		message = OSC::Message.new("Audio / Progress", 'f', progress)

		# send it out
		@socket.send(message.encode, 0, MESSAGE_BUS_IP, MESSAGE_BUS_PORT)		# 0 means calculate the length
	end
end
