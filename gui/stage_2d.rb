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

require 'stage'

class Stage2D < Stage
	def draw_background
		@background_texture ||= Image.new(:repeat => true).from_image_file_path(BACKGROUND_PATTERN_TEXTURE)
		@background_texture.using {
			#fullscreen_rectangle(BACKGROUND_REPEAT / @zoom, BACKGROUND_REPEAT / @zoom)
			with_texture_scale(BACKGROUND_REPEAT / @zoom, BACKGROUND_REPEAT / @zoom) { fullscreen_rectangle }
		}
		# or just: clear_screen(BACKGROUND_COLOR)
	end

	def render(objects)
		using_context {
			GL.PushAll {
				projection
				view
				settings
				draw_background

				GL.Disable(GL::DEPTH_TEST)
				with_scale(@zoom) {
					objects.each { |object| object.render! }
					with_color(MAJOR_GRIDLINE_COLOR) { draw_grid(GRID_SQUARES) }
					draw_guides unless @zoom == 1
					draw_handles(objects)
				}
				GL.Enable(GL::DEPTH_TEST)
			}
		}
		@drawn_objects = objects
	end
end

