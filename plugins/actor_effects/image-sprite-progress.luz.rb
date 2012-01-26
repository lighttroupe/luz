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

class ActorEffectImageSpriteProgress < ActorEffect
	title				"Image Sprite Progress"
	description "Apply one frame of animation from a 'sprite', selected by percentage."

	hint "Supports images containing multiple frames, spaced equally, either horizontally or vertically."

	setting 'image', :image
	setting 'number', :integer, :range => 1..256, :default => 1..2
	setting 'progress', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		image.using {
			# wide images are animated horizontally, tall ones vertically
			if image.width > image.height
				with_texture_scale_and_translate(1.0 / number, 1, number.choose_index_by_fuzzy(progress), 0) {
					yield
				}
			else
				with_texture_scale_and_translate(1, 1.0 / number, 0, number.choose_index_by_fuzzy(progress)) {
					yield
				}
			end
		}
	end
end
