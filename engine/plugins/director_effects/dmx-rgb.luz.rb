class DirectorEffectDMXRGB < DirectorEffect
	title				"DMX RGB"
	description "A basic 3-channel RGB light."

	setting 'channel', :integer, :range => 1..255, :simple => true, :summary => 'channel %'

	setting 'red', :float, :range => 0.0..1.0
	setting 'green', :float, :range => 0.0..1.0
	setting 'blue', :float, :range => 0.0..1.0

	def tick
		$engine.with_dmx(channel) { |dmx|

			# RGB
			dmx.add(1, 255 * red)
			dmx.add(2, 255 * green)
			dmx.add(3, 255 * blue)
		}
	end
end
