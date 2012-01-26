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

class BeatMonitor < Gtk::DrawingArea
	BACKGROUND_COLOR = [0.0, 0.0, 0.0, 1.0]
	BEAT_COLOR = [1.00, 1.00, 1.00, 1.0]

	def initialize
		super
		@saved_beat_scale, @pixel, @last_pixel = 0.0, nil, nil
		signal_connect('expose_event') { draw(@saved_beat_scale) }
	end

	def draw(beat_scale)
		@width ||= allocation.width
		@height ||= allocation.height

		beats_per_measure = $env[:beats_per_measure]
		beat_index = ($env[:beat_number] % beats_per_measure)

		pixel = @height - (beat_scale * @height)
		return if pixel == @last_pixel

		@cr = window.create_cairo_context

		width_each_beat = (1.0 / beats_per_measure) * @width
		start_x = (beat_index * width_each_beat)

		@cr.set_source_rgba(*BEAT_COLOR)

		# Left (all-on) part
		@cr.rectangle(0.0, 0.0, start_x, @height+1)

		# Center (active beat) beat part
		@cr.rectangle(start_x, pixel, width_each_beat, height+1)
		@cr.fill

		@cr.set_source_rgba(*BACKGROUND_COLOR)

		# Center (active beat) background part
		@cr.rectangle(start_x, 0.0, width_each_beat, pixel)

		# Right (all-off) part
	  @cr.rectangle(start_x + width_each_beat, 0.0, @width, @height+1)
		@cr.fill

		# Caching
		@last_pixel, @saved_beat_scale = pixel, beat_scale		# save @saved_beat_scale just so we can redraw if necessary
	end
end
