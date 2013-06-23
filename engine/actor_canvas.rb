 ###############################################################################
 #  Copyright 2008 Ian McIntosh <ian@openanswers.org>
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

multi_require 'cairo_canvas', 'actor_effect_canvas'

class ActorCanvas < Actor
	title				"Canvas"
	description "A canvas upon which certain effects can draw.\n\nThe contents are persistent for the lifetime of the actor, unless erased by effects."

	# setting 'pixels', :options => [:640x480 etc]

	def deep_clone(*args)
		@cairo_canvas, @image, @last_copy_to_texture_frame_number  = nil, nil, nil		# can't clone these
		super(*args)
	end

	def render
		# Copy Cairo surface to OpenGL texture
		if @last_copy_to_texture_frame_number != $env[:frame_number]

			cc = cairo_canvas
			dirty_rects = cc.dirty_rects_clear
			full_draw = cc.entire_canvas_dirty?

			if full_draw or @last_copy_to_texture_frame_number.nil?
				# Do a full copy
				image.from_bgra8(cc.string_data, cc.width, cc.height)
				cc.entire_canvas_dirty = false
			else
				dirty_rects.each { |r|
					# r is [x1,y1,x2,y2] in range -0.5->0.5 (actually beyond this range, as Cairo doesn't clamp to canvas size)

					# Convert to 0.0->1.0 (with clamping)
					x1 = r[0].clamp(-0.5,0.5) + 0.5
					x2 = r[2].clamp(-0.5,0.5) + 0.5

					# Flip vertically, as pixel y=0 is at top, where our canvas has y=0.5 at top
					y1 = 1.0 - (r[3].clamp(-0.5,0.5) + 0.5)
					y2 = 1.0 - (r[1].clamp(-0.5,0.5) + 0.5)

#puts "=> [#{x1}, #{y1}, #{x2}, #{y2}]"

					# Convert to pixel metric
					x1 *= cc.width
					y1 *= cc.height
					x2 *= cc.width
					y2 *= cc.height

					# Calculate width/height, adding one pixel for each edge (to account for float->int rounding)
					width = (x2-x1) + 2
					width = (cc.width - x1) if (x1 + width) > cc.width			# OpenGL complains if x1+width goes outside texture
					height = (y2-y1) + 2
					height = (cc.height - y1) if (y1 + height) > cc.height

					image.from_bgra8_partial(cc.string_data, cc.width, cc.height, x1, y1, width, height)
				}
			end
			@last_copy_to_texture_frame_number = $env[:frame_number]
		end

		# Fullscreen rect with our texture
		image.using { fullscreen_rectangle }
	end

	def with_canvas
		cairo_canvas.using { |context| yield context }
	end

	def cairo_canvas
		@cairo_canvas ||= new_cairo_canvas
	end

	def image
		@image ||= new_image
	end

	def new_image
		Image.new
	end

	def new_cairo_canvas
		w, h = 1024, 1024		# TODO: some way to choose the size?
		cc = CairoCanvas.new(w, h)
		cc.track_dirty_rects = true

		cc.using { |context|
			# Clear canvas to transparent
			context.save
				context.set_source_rgba(0.0, 0.0, 0.0, 0.0)
				context.set_operator(:source)
				context.paint
			context.restore

			# Default Cairo coordinates has 0,0 in the upper left, with 1 unit translating to 1 pixel
			# Scale it so that the whole canvas goes 0.0 -> 1.0 horizontally and 0.0 -> 1.0 vertically
			context.scale(w, -h)		# NOTE: height is multiplied by -1 to flip the canvas vertically, so bigger numbers go up (cartessian plane)

			# Move cursor to center
			context.translate(0.5, -0.5)

			context.set_source_rgba(1,1,1,1)
			context.set_antialias(Cairo::ANTIALIAS_GRAY)		# or DEFAULT or GRAY or SUBPIXEL or NONE
		}
		cc
	end
end
