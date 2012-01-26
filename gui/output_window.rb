 ###############################################################################
 #  Copyright 2009 Ian McIntosh <ian@openanswers.org>
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

require 'gtk_gl_drawing_area'

class OutputWindow < Gtk::Window
	boolean_accessor :visible

	def initialize
		super
		@drawing_area = GtkGLDrawingArea.new.show
		add(@drawing_area)

		# don't destroy on X or Alt-F4, etc.
		on_close { hide }

		# Three easy options to toggle fullscreen
		on_double_click { toggle_fullscreen }
		on_key_press(Gdk::Keyval::GDK_Return) { toggle_fullscreen }
		on_key_press(Gdk::Keyval::GDK_Escape) { toggle_fullscreen }

		self.title = 'Luz Studio Output Window'
	end

	def show
		super
		using_context { $engine.render_settings }
		self.visible = true
	end

	def hide
		super
		self.visible = false
	end

	def using_context
		@drawing_area.using_context { yield }
	end
end
