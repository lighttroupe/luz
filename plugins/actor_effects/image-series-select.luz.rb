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

class ActorEffectImageSeriesSelect < ActorEffect
	title				"Image Series Select"
	description "Apply one of a series of images to actor, selected by forwards and backwards events."

	hint "Supports animated GIFs, and will some day also support video files."

	setting 'image', :image, :summary => true

	setting 'forwards', :event
	setting 'backwards', :event

	def render
		image_setting.using_index(forwards.count - backwards.count) {
			yield
		}
	end
end
