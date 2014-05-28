class DirectorEffectDMXMartinMX10Extreme < DirectorEffect
	title				"DMX Martin MX-10 Extreme"
	description "A 13-channel 250 watt spotlight with pan, tilt, strobe, color wheel, prism effect, and gobo selection and rotation control."

	setting 'channel', :integer, :range => 1..255, :simple => true, :summary => 'channel %'

	setting 'brightness', :float, :range => 0.0..1.0
	setting 'strobe', :float, :range => 0.0..1.0
	setting 'pan', :float, :range => 0.0..1.0
	setting 'tilt', :float, :range => 0.0..1.0
	setting 'focus', :float, :range => 0.0..1.0
	setting 'color', :float, :range => 0.0..1.0
	setting 'prism', :float, :range => 0.0..1.0

	setting 'gobo_selection', :float, :range => 0.0..1.0
	setting 'gobo_rotation', :float, :range => 0.0..1.0

	def tick
		$engine.with_dmx(channel) { |dmx|
			# This is needed to turn on the light
			dmx.set(1, 245)

			#
			# Brightness
			#
			dmx.set(2, 255 * brightness)

			#
			# Color
			#
			dmx.set(3, 144 * color)

			#
			# Gobo Selection
			#
			dmx.set(4, 45 + (40 * gobo_selection))

			#
			# Gobo Rotation
			#
			if gobo_rotation == 0.0
				dmx.set(5, 0)
			else
				dmx.set(5, 3 + (124 * gobo_rotation))
			end

			#
			# Focus
			#
			dmx.set(6, (255 * focus).to_i)

			#
			# Prism
			#
			if prism == 0.0
				dmx.set(7, 0)
			else
				dmx.set(7, 79 - (59 * prism).to_i)
			end

			dmx.set(8, (255 * pan).to_i)
			# pan fine dmx.set(c + 8, (255 * pan).to_i)

			dmx.set(10, (255 * tilt).to_i)
			# tilt fine dmx.set(c + 10, (255 * pan).to_i)
		}
	end
end
