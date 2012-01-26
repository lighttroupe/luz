require 'gst'
require 'utils/callbacks'

class GStreamerAudioPlayer
	PIPELINE_NAME = "audio-player"

	include Callbacks
	callback :position_changed		# the play position changed
	callback :duration_changed		# the song length changed (possible with a VBR file, or a new song loaded)

	callback :state_changed				#

	attr_reader :state, :duration_in_ms, :position_in_ms

	def initialize
		build_pipeline
	end

	def open(file)
		@source.location = file
	end

	def play
		@pipeline.play
	end

	def pause
		@pipeline.pause
	end

	def seek_to_ms(position_in_ms)
		@pipeline.send_event(Gst::EventSeek.new(1.0, Gst::Format::Type::TIME, Gst::Seek::FLAG_FLUSH.to_i | Gst::Seek::FLAG_KEY_UNIT.to_i, Gst::Seek::TYPE_SET, position_in_ms * 1000000, Gst::Seek::TYPE_NONE, -1))
	end

	def stop
		@pipeline.stop
	end

	def volume=(volume)
		@pipeline.volume = volume
	end

private

	def build_pipeline
		# GStreamer Pipeline
		@pipeline = Gst::Pipeline.new(PIPELINE_NAME)

		# File Reader
		@source = Gst::ElementFactory.make('filesrc')

		# Audio Decoder
		@convertor = Gst::ElementFactory.make('audioconvert')
		@decoder = Gst::ElementFactory.make('decodebin')

		# Audio Output
		@sink = Gst::ElementFactory.make('alsasink')

		#
		# Link it all together
		#
		@decoder.signal_connect('new-decoded-pad') do | dbin, pad, is_last |
			pad.link(@convertor.get_pad('sink'))
			@convertor >> @sink
		end

		@pipeline.add @source, @decoder, @convertor, @sink
		@source >> @decoder

		self.state = :stopped

		#
		# Watch for pipeline state changes
		#
		@pipeline.bus.add_watch { | bus, message |
			case message.type
				when Gst::Message::Type::ERROR
					puts 'Encountered GStreamer Error', message.structure['debug']
					@pipeline.stop
					self.position_in_ms = 0.0
					self.state = :error

				when Gst::Message::Type::STATE_CHANGED
					if message.source.name == PIPELINE_NAME
						if message.structure['new-state'] == Gst::State::PLAYING
							GLib::Timeout.add(15) { update_position }
							self.state = :playing

						elsif message.structure['new-state'] == Gst::State::PAUSED
							# pipeline passes through PAUSED state
							# it's the right time to request the song length
							q = Gst::QueryDuration.new(Gst::Format::TIME)
							@pipeline.query(q)
							@duration_in_ms = q.parse[1] / 1000000
							duration_changed_notify
							self.state = :paused
						end
					end

				when Gst::Message::Type::EOS
					stop
					self.position_in_ms = 1.0		# ensure it's at 1.0
					state_changed_notify(:stopped)
			end

			true	# we want more messages
		}
	end

	def update_position
		# read latest position from GStreamer
		q = Gst::QueryPosition.new(Gst::Format::TIME)
		@pipeline.query(q)
		self.position_in_ms = (q.parse[1] / 1000000)
	end

	def position_in_ms=(pos)
		@position_in_ms = pos
		position_changed_notify
	end

	def state=(state)
		@state = state
		state_changed_notify(state)
	end
end
