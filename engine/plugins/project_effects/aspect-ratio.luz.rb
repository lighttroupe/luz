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

class ProjectEffectAspectRatio < ProjectEffect
	title				"Aspect Ratio"
	description "Adjusts aspect ratio for the display in use to ensure that square objects appear square."

	hint "Place this before drawing Directors."

	setting 'mode', :select, :default => :stretched, :options => [[:stretched, 'Stretched'], [:square_horizontal, 'Square (stretch horizontally)'], [:square_vertical, 'Square (stretch vertically)']]

	def render
		ratio = ($application.width.to_f / $application.height)

		# ratio is a number above 1.0 for most monitors
		case mode
		when :stretched		# 1x1 shapes appear stretched horizontally (normal luz behavior)
			yield

		when :square_horizontal
			with_scale(1.0 / ratio, 1.0) {
				with_env(:aspect_scale, ratio) {		# this informs anything about the need to scale larger to fill the screen
					yield
				}
			}

		when :square_vertical
			with_scale(1.0, 1.0 * ratio) {
				yield
			}

		else
			raise "unhandled mode '#{mode}'"
		end
	end
end
