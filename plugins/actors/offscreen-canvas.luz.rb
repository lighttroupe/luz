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

	setting 'pages', :integer, :range => 1..100, :default => 1..6
	setting 'forward', :event
	setting 'backward', :event
	#setting 'previous_color', :color, :default => [1.0, 1.0, 1.0, 0.2]

	hint 'The drawn image is persistent, unless erased by effects.'

	FBO_USING_OPTIONS = {:clear => false}

	def after_load
		@fbos ||= Hash.new { |hash, key| hash[key] = create_fbo }
	end

	def render
		current_fbo.with_image { unit_square }
	end

	# 'using' is called by the actor_effects that draw on us
	def using
		current_fbo.using(FBO_USING_OPTIONS) {
			yield
		}
	end

private

	def create_fbo
		FramebufferObject.new(:height => 1024, :width => 1024)
	end

	def current_fbo
		@fbos[page_index]
	end

	def page_index
		(forward.count - backward.count) % pages
	end
end
