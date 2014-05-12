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

require 'plugins/project_effects/screen-capture.luz.rb'

class ProjectEffectScreenCaptureWithThemeStorage < ProjectEffectScreenCapture
	title				"Screen Capture w/ Theme Storage"
	description "Like Screen Capture, but also stores "

	setting 'container', :theme

	def save_to_theme(pixels)
		@capture_index ||= 0

		style = container.effects[@capture_index]
		style.set_pixels(pixels, $application.width, $application.height)

		@capture_index = (@capture_index + 1) % container.effects.size
	end

	def tick
		if (event.now? and $gui.nil?)	# NOTE: only operates in performer
			output_filepath = generate_output_filepath

			# Get pixels and write them to temporary file
			return if (pixels = get_framebuffer_rgb8).nil?

			save_to_theme(pixels)
			save_pixels_to_path(pixels, output_filepath)
		end
	end
end
