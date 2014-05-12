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

require 'framebuffer_object'

module DrawingFramebufferObjects
	DEFAULT_FRAMEBUFFER_SIZE = :large
	FRAMEBUFFER_SIZES = {:large => {:width => 1024, :height => 768}, :medium => {:width => 512, :height => 384}, :small => {:width => 256, :height => 192}}

	def get_offscreen_buffer(size = DEFAULT_FRAMEBUFFER_SIZE)
		@fbo_to_size ||= {}			# so we know which stack to return it to
		@fbo_hash ||= {}				# hash[size] => [fbo, fbo, ...]
		@fbo_hash[size] ||= []

		if @fbo_hash[size].empty?
			fbo = FramebufferObject.new(FRAMEBUFFER_SIZES[size])
			@fbo_to_size[fbo] = size		# record size of new framebuffer
			fbo
		else
			@fbo_hash[size].pop
		end
	end

	def return_offscreen_buffer(fbo)
		@fbo_hash[@fbo_to_size[fbo]] << fbo
	end

	def with_offscreen_buffer(size = DEFAULT_FRAMEBUFFER_SIZE)
		fbo = get_offscreen_buffer(size)
		yield fbo
		return_offscreen_buffer(fbo)
	end
end
