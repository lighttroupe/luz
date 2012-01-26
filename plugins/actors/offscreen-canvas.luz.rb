 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
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

class ActorOffscreenCanvas < Actor
	title				"Canvas"
	description "A canvas upon which the Actor Render or Actor Pen plugins can draw."

	hint 'The drawn image is persistent, unless erased by effects.'

	def render
		@fbo.with_image { unit_square } if @fbo		# transparent unless some rendering has been done
	end

	FBO_USING_OPTIONS = {:clear => false}

	def using
		@fbo ||= FramebufferObject.new(:height => 1024, :width => 1024)
		@fbo.using(FBO_USING_OPTIONS) {
			yield
		}
	end
end
