require 'glade_window'
require 'reloadable_require'

load_directory(File.join(Dir.pwd, 'utils', 'addons'), '**.rb')

require 'fileutils'
require 'gstreamer_audio_player'
require 'exception_addons'

require 'utils/osc'
require 'utils/ip_socket'		# for IPSocket#set_reuse_address_flag

require 'utils/unique_timeout_callback'

require 'constants'		# for MESSAGE_BUS_IP and MESSAGE_BUS_PORT

class AudioPlayerWindow < GladeWindow
	def initialize
		super

		#
		# Socket
		#
		@socket = UDPSocket.new.set_reuse_address_flag
		@socket.bind(Socket::INADDR_ANY, 0)
		@socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

		#
		# Audio Player
		#
		@audio_player = GStreamerAudioPlayer.new
		@audio_player.on_position_changed {
			# calculate progress as 0.0..1.0
			@current_progress = @audio_player.position_in_ms.to_f / @audio_player.duration_in_ms.to_f
		}

		@sender_callback = UniqueTimeoutCallback.new(1000 / 30) {
			if @current_progress != @last_progress
				send_progress(@current_progress)
				@last_progress = @current_progress
			end
		}

#		@audio_player.on_duration_changed {
#			@duration_label.text = sprintf('%3.3f secs', @audio_player.duration_in_ms.to_f / 1000.0)
#		}

		#
		# Play/Pause button
		#
		@play_image = Gtk::Image.new(Gtk::Stock::MEDIA_PLAY, Gtk::IconSize::BUTTON).show
		@pause_image = Gtk::Image.new(Gtk::Stock::MEDIA_PAUSE, Gtk::IconSize::BUTTON).show

		@play_button_image_container.add(@current_image = @play_image)
		@audio_player.on_state_changed { |state|
			@play_button_image_container.remove(@current_image)
			if state == :playing
				@sender_callback.start
				@play_button_image_container.add(@current_image = @pause_image)
			else
				@sender_callback.stop
				@play_button_image_container.add(@current_image = @play_image)
			end
		}

		#
		# Seekbar
		#
		@seek_callback = UniqueTimeoutCallback.new(50) {
			@audio_player.seek_to_ms(@progress_bar_hscale.value * @audio_player.duration_in_ms)
		}


		# volume button
		@volumebutton.set_value(1.0)
		@volumebutton.signal_connect('value-changed') { |widget, value| @audio_player.volume = value }		# value is 0.0-1.0
	end

	def on_delete_event
		Gtk.main_quit		# quit app when main window is closed
	end

	def on_progress_bar_value_changed
		@seek_callback.set
	end

	def on_play_button_clicked
		if @audio_player.state == :playing
			@audio_player.pause
		else
			@audio_player.play
		end
	end

	def on_file_chosen
		@audio_player.stop
		@audio_player.open(@file_chooser_button.filename)
	end

	def send_progress(progress)
		# create OSC message
		message = OSC::Message.new("Audio / Progress", 'f', progress)

		# send it out
		@socket.send(message.encode, 0, MESSAGE_BUS_IP, MESSAGE_BUS_PORT)		# 0 means calculate the length
	end
end
