# osc.rb: Written by Tadayoshi Funaba 2005,2006
# $Id: osc.rb,v 1.4 2006-11-10 21:54:37+09 tadf Exp $

# Modified by Ian McIntosh for the Luz project

require 'forwardable'
require 'socket'
require 'thread'

module OSC
	# NOTE: using constants instead of literals reduces garbage production

	#
	# OSC type tags
	#
	INT32_TAG = 'i'
	FLOAT32_TAG = 'f'
	STRING_TAG = 's'
	BLOB_TAG = 'b'
	CAPITAL_S = 'S'		# TODO: what is this?
	EMPTY_TAG = ''

	#
	# pack() method format options
	#
	INT32_PACK_FORMAT = 'N'
	FLOAT32_PACK_FORMAT = 'g'

	#
	# misc
	#
	ZERO_BYTE_STRING = "\000"
	HASH_BUNDLE = '#bundle'

	class OSCArgument
		attr_accessor :val

		def initialize(val)
			@val = val
		end

		def to_i() @val.to_i end
		def to_f() @val.to_f end
		def to_s() @val.to_s end

	private

		def padding(s)
			s + (ZERO_BYTE_STRING * ((4 - (s.size % 4)) % 4))
		end
	end

	class OSCInt32 < OSCArgument
		def tag() INT_TAG end
		def encode() [@val].pack(INT32_PACK_FORMAT) end
	end

	class OSCFloat32 < OSCArgument
		def tag() FLOAT32_TAG end
		def encode() [@val].pack(FLOAT32_PACK_FORMAT) end
	end

	class OSCString < OSCArgument
		def tag() STRING_TAG end
		def encode() padding(@val.sub(/\000.*\z/, '') + ZERO_BYTE_STRING) end
	end

	class OSCBlob < OSCArgument
		def tag() BLOB_TAG end
		def encode() padding([@val.size].pack(INT32_PACK_FORMAT) + @val) end
	end

	class Packet
		class PO
			def initialize(str)
				@str, @index, @remaining_bytes = str, 0, str.length
			end

			def use(str)
				@str, @index, @remaining_bytes = str, 0, str.length
				self
			end

			def eof? ()
				@remaining_bytes <= 0
			end

			def skip(n)
				@index += n
				@remaining_bytes -= n
			end

			def skip_padding()
				skip((4 - (@index % 4)) % 4)
			end

			def getn(n)
				raise EOFError if @remaining_bytes < n
				s = @str[@index, n]
				skip(n)
				return s
			end

			def getc
				raise EOFError if @remaining_bytes < 1
				c = @str[@index]
				skip(1)
				return c
			end

			def get_until_zero_byte
				# find a 0, starting at @index
				start_index = @index
				zero_index = @str.index(ZERO_BYTE_STRING, start_index)
				raise EOFError unless zero_index

				# how many bytes from @index to zero_index?
				length = zero_index - @index

				# Consume the bytes, including the zero
				skip(length + 1)

				return @str[start_index, length]		# Return all but the zero byte
			end
		end

		def self.decode_int32(io)
			i = io.getn(4).unpack(INT32_PACK_FORMAT)[0]
			i -= 2**32 if i > (2**31-1)
			return i
		end

		def self.decode_float32(io)
			f = io.getn(4).unpack(FLOAT32_PACK_FORMAT)[0]
			return f
		end

		def self.decode_string(io)
			s = io.get_until_zero_byte
			io.skip_padding
			return s
		end

		def self.decode_blob(io)
			length = io.getn(4).unpack(INT32_PACK_FORMAT)[0]
			b = io.getn(length)
			io.skip_padding
			return b
		end

		def self.decode_timetag(io)
			t1 = io.getn(4).unpack(INT32_PACK_FORMAT)[0]
			t2 = io.getn(4).unpack(INT32_PACK_FORMAT)[0]
			return [t1, t2]
		end

		@@po = PO.new('')		# a single reusable PO object

		def self.decode(data, &proc)
			io = @@po.use(data)
			decode_io(io, &proc)
		end

		def self.decode_io(io, &proc)
			# Packets start with OSC address
			address = decode_string(io)

			# Special BUNDLE address
			if address == HASH_BUNDLE
				decode_timetag(io)		# bundle start with a timestamp; eat it

				# Now a list of [4 byte length][length-byte data] until the end
				until io.eof?
					length = io.getn(4).unpack(INT32_PACK_FORMAT)[0]		# length
					string = io.getn(length)														# data
					decode_io(PO.new(string), &proc)
				end

			# A comma begins list of "tags" (parameter types)
			elsif io.getc == ?,
				tags = decode_string(io)

				# Simply hardcoded support for two types of single-parameter messages
				if tags == FLOAT32_TAG
					proc.call(address, decode_float32(io))
				elsif tags == INT32_TAG
					proc.call(address, decode_int32(io))
				elsif tags == EMPTY_TAG		# consider this a "bang" ... a button press
					proc.call(address, 1)
					proc.call(address, 0)
				end

				#
				# currently unsupported types
				#
				#when STRING_TAG
				#	@@args << s decode_string(io)
				#when BLOB_TAG
				#	b = decode_blob(io)
				#	@@args << OSCBlob.new(b)
				#when /[htd]/; io.read(8)
				#when CAPITAL_S; decode_string(io)
				#when /[crm]/; io.read(4)
				#when /[TFNI\[\]]/;
				#end
			end
		end

		private_class_method :decode_int32, :decode_float32, :decode_string, :decode_blob, :decode_timetag
	end

	class Message < Packet
		def initialize(address, tags=nil, *args)
			@address = address
			@args = []
			args.each_with_index do |arg, i|
				if tags && tags[i]
					case tags[i]
					when ?i; @args << OSCInt32.new(arg)
					when ?f; @args << OSCFloat32.new(arg)
					when ?s; @args << OSCString.new(arg)
					when ?b; @args << OSCBlob.new(arg)
					when ?*; @args << arg
					else; raise ArgumentError, 'unknown type'
					end
				else
					case arg
					when Integer;     @args << OSCInt32.new(arg)
					when Float;       @args << OSCFloat32.new(arg)
					when String;      @args << OSCString.new(arg)
					when OSCArgument; @args << arg
					end
				end
			end
		end

		attr_accessor :address, :args

		def tags() ',' + @args.collect{|x| x.tag}.join end

		def encode
			s = OSCString.new(@address).encode
			s << OSCString.new(tags).encode
			s << @args.collect{|x| x.encode}.join
		end

		def to_a() @args.collect{|x| x.val} end

		extend Forwardable
		include Enumerable

		de = (Array.instance_methods - self.instance_methods)
		de -= %w(assoc flatten flatten! pack rassoc transpose)
		de += %w(include? sort)

		def_delegators(:@args, *de)

		undef_method :zip
	end

	class Bundle < Packet
		def encode_timetag(t)
			case t
			when NIL # immediately
				t1 = 0
				t2 = 1
			when Numeric
				t1, fr = t.divmod(1)
				t2 = (fr * (2**32)).to_i
			when Time
				t1, fr = (t.to_f + 2208988800).divmod(1)
				t2 = (fr * (2**32)).to_i
			else
				raise ArgumentError, 'invalid time'
			end
				[t1, t2].pack('N2')
		end

		private :encode_timetag

		def initialize(timetag=nil, *args)
			@timetag = timetag
			@args = args
		end

		attr_accessor :timetag

		def encode()
			s = OSCString.new(HASH_BUNDLE).encode
			s << encode_timetag(@timetag)
			s << @args.collect{|x|
				x2 = x.encode
				[x2.size].pack(INT32_PACK_FORMAT) + x2
			}.join
		end

		extend Forwardable
		include Enumerable

		def to_a() @args.collect{|x| x.to_a} end

		de = (Array.instance_methods - self.instance_methods)
		de -= %w(assoc flatten flatten! pack rassoc transpose)
		de += %w(include? sort)

		def_delegators(:@args, *de)

		undef_method :zip
	end
end
