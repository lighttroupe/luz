 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

class DirectorEffectDMXChauvetMinSpotRGBW < DirectorEffect
	title				"DMX Chauvet MinSpot RGBW"
	description "A 14-channel LED spotlight with RGBW, pan, tilt, strobe, and gobo selection control."

	setting 'channel', :integer, :range => 1..255, :simple => true, :summary => 'channel %'

	setting 'red', :float, :range => 0.0..1.0
	setting 'green', :float, :range => 0.0..1.0
	setting 'blue', :float, :range => 0.0..1.0
	setting 'white', :float, :range => 0.0..1.0

	setting 'gobo_selection', :integer, :range => 1..10, :default => 1..2

	setting 'strobe', :float, :range => 0.0..1.0

	setting 'pan', :float, :range => 0.0..1.0, :digits => 5, :step => 0.00001
	setting 'tilt', :float, :range => 0.0..1.0, :digits => 5, :step => 0.00001

	def tick
		$engine.with_dmx(channel) { |dmx|
			# Pan (0-540 deg)
			pan_per_integer = (1.0 / 255)
			dmx.add(1, 255 * pan)

			# Fine Pan (0-3 deg)
			fine_pan = (pan % pan_per_integer).to_f / pan_per_integer
			dmx.add(2, 255 * fine_pan)

			# Tilt (0-270 deg)
			tilt_per_integer = (1.0 / 255)
			dmx.add(3, 255 * tilt)

			# Fine Tilt (0-3 deg)
			fine_tilt = (tilt % tilt_per_integer).to_f / tilt_per_integer
			dmx.add(4, 128 * fine_tilt)		# 270/255=1.06 deg per tick, 3*(128/255)=1.5 deg, but with latency this looks smooth

			# Pan/Tilt Speed
			dmx.set(5, 0)		# 0 = max

			# Strobe
			if strobe == 0.0
				dmx.set(6, 8)
			else
				dmx.set(6, 239 - (strobe * 60))
			end

			# RGBW
			dmx.add(7, 255 * red)
			dmx.add(8, 255 * green)
			dmx.add(9, 255 * blue)
			dmx.add(10, 255 * white)

			# Color Speed
			dmx.set(12, 0)		# 0 = max

			# Gobo
			dmx.set(14, ((gobo_selection - 1) * 13) % 128)
		}
	end
end
