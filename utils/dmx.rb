#
# DMX support, specifically targeting the "Enttec DMX USB Pro" device
#
require 'serialport'

class DMX
	START_OF_MESSAGE = "\x7E"
	SEND_DMX_LABEL   = "\x06"	# ID of the message type we send, DMX channel values
	START_OF_DATA    = "\x00"
	END_OF_MESSAGE   = "\xE7"

	SERIAL_PORT_PARAMS = {
		'baud' => 115_200,
		'data_bits' => 8,
		'stop_bits' => 2,
		'parity' => SerialPort::NONE
	}

	#
	# Wikipedia says "A maximum-sized packet, which has 512 channels, takes
	# approximately 23 ms to send, corresponding to a max refresh rate of ~44 Hz.
	# For higher refresh rates, packets having fewer than 512 channels can be sent.
	#
	def initialize(path, channel_count)
		raise ArgumentError.new("channel_count must be between 25 and 512") if (channel_count < 25 or channel_count > 512)

		@path, @channel_count = path, channel_count

		@port = SerialPort.new(@path, SERIAL_PORT_PARAMS)

		# Allocate a buffer once, so we don't continually produce garbage
		@packet = "\0" * (@channel_count + 6)		# 6 bytes of START_OF_MESSAGE, etc.
		@clear_string = "\0" * @channel_count

		# Set the static values
		@packet[0] = START_OF_MESSAGE
		@packet[1] = SEND_DMX_LABEL
		payload_size = (@channel_count + 1)		# +1 is for the start code
		@packet[2] = (payload_size & 255).chr					# LSB of size
		@packet[3] = ((payload_size >> 8) & 255).chr	# MSB of size
		@packet[4] = START_OF_DATA
		# @channel_count bytes of DMX channels
		@packet[4 + @channel_count + 1] = END_OF_MESSAGE

		@starting_channel = 1
	end

	def with_starting_channel(channel)
		return yield if channel == @starting_channel

		raise ArgumentError.new("channel out of range") if (channel < 1 or channel > @channel_count)
		old_starting_channel = @starting_channel
		@starting_channel = channel
		yield
		@starting_channel = old_starting_channel
	end

	def set(channel, value)
		channel_with_offset = channel + (@starting_channel - 1)
		raise ArgumentError.new("channel out of range") if (channel_with_offset < 1 or channel_with_offset > @channel_count)
		@packet[5 + channel_with_offset - 1] = value.to_i.chr
	end

	def get(channel)
		channel_with_offset = channel + (@starting_channel - 1)
		raise ArgumentError.new("channel out of range") if (channel_with_offset < 1 or channel_with_offset > @channel_count)
		@packet[5 + channel_with_offset - 1].ord
	end

	# Helper method
	def add(channel, value)
		set(channel, (get(channel) + value).clamp(0, 255))
	end

	def send
		begin
			@port.write(@packet)
		rescue Errno::EIO
			# ignore?
		rescue Exception => e
			puts "Exception writing to DMX serial port: #{e}"
		end
	end

	def clear
		@packet[5, @channel_count] = @clear_string
	end
end

#
# Example usage
#
=begin
	dmx = DMX.new('/dev/ttyUSB0', 256)
	v = 1
	loop {
		# Test values for a Chauvet Colorsplash JR
		dmx.set(1, 0)								# reserved
		dmx.set(2, 255)							# brightness
		dmx.add(3, v % 255)					# R
		dmx.add(4, 0)								# G
		dmx.add(5, 255 - (v % 255))	# B
		dmx.send
		v += 1
	}
=end
