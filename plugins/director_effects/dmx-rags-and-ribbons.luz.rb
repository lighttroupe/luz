 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
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

class DirectorEffectDMXRagsAndRibbons < DirectorEffect
	title				"DMX RagsAndRibbons"
	description "Custom DMX show controller."

	setting 'channel', :integer, :range => 1..255, :simple => true, :summary => 'channel %'

	setting 'red', :float, :range => 0.0..1.0
	setting 'green', :float, :range => 0.0..1.0
	setting 'blue', :float, :range => 0.0..1.0
	setting 'strobe', :float, :range => 0.0..1.0

	setting 'actor', :actor

	ColorSplashJr = DirectorEffectDMXChauvetColorSplashJR

	def after_load
		@lights = [
				ColorSplashJr.new.set_channel(9),
				ColorSplashJr.new.set_channel(5),
				ColorSplashJr.new.set_channel(1)
			]
		super
	end

	def tick
		if actor.present?
			actor.one { |a|
				with_env(:total_children, @lights.size) {		# this can have an effect on the resulting color set
					@lights.each_with_index { |light, index|
						with_env(:child_index, index) {		# this can have an effect on the resulting color set
							a.render_recursive {
								color = GL.GetColorArray
								light.red, light.green, light.blue = color[0]*color[3], color[1]*color[3], color[2]*color[3]
							}
						}
					}
				}
			}
		else
			@lights.each_with_index { |light, index|
				light.blue = (rand * 0.5)
			}
		end
		# Let lights do their work!
		@lights.each { |light| light.tick }
	end
end
