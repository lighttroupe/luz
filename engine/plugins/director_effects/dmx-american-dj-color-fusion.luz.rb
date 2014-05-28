class DirectorEffectDMXAmericanDJColorFusion < DirectorEffect
	title				"DMX American DJ Color Fusion"
	description "A 7-channel, 3x300 watt light with RGB and strobe control."

	setting 'channel', :integer, :range => 1..255, :simple => true, :summary => 'channel %'

	setting 'red', :float, :range => 0.0..1.0
	setting 'green', :float, :range => 0.0..1.0
	setting 'blue', :float, :range => 0.0..1.0

	setting 'strobe', :float, :range => 0.0..1.0

	def tick
		$engine.with_dmx(channel) { |dmx|
			# RBG (note order)
			dmx.add(1, 255 * red)
			dmx.add(2, 255 * blue)
			dmx.add(3, 255 * green)
			dmx.set(6, 200 * strobe)
		}
	end
end
