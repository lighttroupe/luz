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
			dmx.set(1, 0)		# Channel 1 is "Rainbow"

			# RGB
			dmx.add(2, 255 * red)
			dmx.add(3, 255 * green)
			dmx.add(4, 255 * blue)

			dmx.set(5, 0)		# TODO: strobe (001-255 1-20 hz)
			dmx.set(6, 0)
		}
	end
end
