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

class GtkGLDrawingArea < Gtk::DrawingArea
	@@shared_gl_context = nil

	def initialize
		super

		@@glconfig ||= Gdk::GLConfig.new(Gdk::GLConfig::MODE_DEPTH | Gdk::GLConfig::MODE_STENCIL | Gdk::GLConfig::MODE_DOUBLE | Gdk::GLConfig::MODE_RGBA)
		@@glconfig ||= Gdk::GLConfig.new(Gdk::GLConfig::MODE_DEPTH | Gdk::GLConfig::MODE_DOUBLE | Gdk::GLConfig::MODE_RGBA)
		@@glconfig ||= Gdk::GLConfig.new(Gdk::GLConfig::MODE_DEPTH | Gdk::GLConfig::MODE_RGBA)
		throw 'Failed to initialize OpenGL' unless @@glconfig

		set_gl_capability(@@glconfig, @@shared_gl_context)

		self.signal_connect('configure_event') { |widget, event| gl_drawable.gl_begin(gl_context) { GL.Viewport(0, 0, width, height) } }
		self.signal_connect('realize') { |__unused_widget, __unused_event|
			@@shared_gl_context ||= gl_context
			@gl_drawable = gl_drawable
			@is_double_buffered = @gl_drawable.double_buffered?
		}
	end

	def width ; allocation.width ; end
	def height ; allocation.height ; end

	# Let caller render (using OpenGL calls) within our gl_context
	def using_context
		@gl_drawable.gl_begin(gl_context) { yield }
		finalize_frame
	end

	def using_context_without_finalize
		@gl_drawable.gl_begin(gl_context) { yield }
	end

	def finalize_frame
		#GL.Flush		# TODO: is this needed?
		@gl_drawable.swap_buffers if @is_double_buffered
	end
end
