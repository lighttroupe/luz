 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 ###############################################################################

class DirectorEffectDMXElationOctostrip < DirectorEffect
	title				"DMX Elation Octostrip"
	description "A 6-channel DMX bar available in groups of 8, driven by a PixelDrive."

	hint "Set the PixelDrive to mode 1 and use one plugin per light."

	setting 'channel', :integer, :range => 1..255, :simple => true, :summary => 'channel %'

	setting 'red', :float, :range => 0.0..1.0
	setting 'green', :float, :range => 0.0..1.0
	setting 'blue', :float, :range => 0.0..1.0

	setting 'strobe', :float, :range => 0.0..1.0

	def tick
		$engine.with_dmx(channel) { |dmx|
			# Channel 1 is "Rainbow"
			dmx.set(1, 0)
			dmx.set(2, 0)
			dmx.set(3, 0)
			dmx.set(4, 0)
			dmx.set(5, 0)
			dmx.set(6, 0)

			# 0 Off
			# 001-255 1-20 hz
#			if strobe == 0.0
				dmx.set(5, 0)
#			else
#				dmx.set(5, 1 + (strobe * 254))
#			end

			# RGB
			dmx.add(2, 255 * red)
			dmx.add(3, 255 * green)
			dmx.add(4, 255 * blue)
		}
	end
end
