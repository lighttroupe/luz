module EngineDMX
	def with_dmx(channel_offset = 1)
		init_dmx if @dmx.nil?
		if @dmx
			@dmx.with_starting_channel(channel_offset) {
				yield @dmx
			}
		end
	end

private

	DMX_CHANNEL_COUNT = 256		# for ~88 hz refresh rate
	def init_dmx
		require 'dmx'

		# TODO: find a better method of finding the device
		@dmx ||= DMX.new("/dev/ttyUSB0", DMX_CHANNEL_COUNT) rescue nil
		@dmx ||= DMX.new("/dev/ttyUSB1", DMX_CHANNEL_COUNT) rescue nil
		@dmx ||= DMX.new("/dev/ttyUSB2", DMX_CHANNEL_COUNT) rescue nil

		if @dmx
			# Send at end of frame and retry dmx_init
			self.on_frame_end { @dmx.send ; @dmx.clear } if @dmx

			# turn off lights when quiting
			ObjectSpace.define_finalizer(self, proc { @dmx.clear ; @dmx.send }) if @dmx
		else
			@dmx = false		# mark as init failed

			# retry dmx_init on reload
			self.on_reload { @dmx = nil if @dmx === false }
		end
	end
end
