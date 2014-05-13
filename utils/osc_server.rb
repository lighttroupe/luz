#
# OSCServer is a non-blocking UDP server that parses each packet as OpenSoundControl
#
# https://en.wikipedia.org/wiki/User_Datagram_Protocol
#
# https://en.wikipedia.org/wiki/Open_Sound_Control
#
require 'socket'
require 'ipaddr'
require 'osc'

class IPSocket
	def set_reuse_address_flag
		setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)			# this allows us to run twice without the socket complaining (OS won't necessarily deliver packets to both sockets, though)
		self
	end
end

class OSCServer
	READ_LIMIT = 1024*8   # any big number (NOTE: too big and read_nonblock sometimes takes a really long time...)

	attr_reader :ignored_message_count, :error_count

	def initialize
		@socket = UDPSocket.new.set_reuse_address_flag
		@socket_array = [@socket]
		@ignored_message_count, @error_count = 0, 0
	end

	def on_new_message(address, args)
		raise NotImplementedError		# override
	end

	def listen(address, port)
		ip = IPAddr.new(address).hton + IPAddr.new('0.0.0.0').hton
		@socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip) rescue Errno::ENODEV	# don't die if there are no networks present to do this on
		@socket.bind(Socket::INADDR_ANY, port)
		self
	end

	def update(max_packets=nil)
		begin
			loop {
				# check readability of socket to avoid generating unnecessary Errno::EAGAIN exceptions
				return if IO.select(@socket_array, nil, nil, 0).nil?

				data = @socket.read_nonblock(READ_LIMIT)

				OSC::Packet.decode(data) { |address, args| on_new_message(address, args) }
				max_packets -= 1 if max_packets

				return if max_packets == 0
			}
		rescue Errno::EAGAIN
			# This is thrown by read_nonblock when there is no more data to read
			return
		rescue Exception => e
			puts e.report_format
			@error_count += 1
			return
		end
	end
end

