 ###############################################################################
 #  Copyright 2010 Ian McIntosh <ian@openanswers.org>
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

require 'glade_window'

class AboutWindow < GladeWindow
	def initialize
		super

		on_key_press(Gdk::Keyval::GDK_Escape) { hide }

		@application_name_label.markup = "<b><big><big>#{APP_NAME}</big></big></b>"
		@version_label.markup = "<small>Version #{APP_VERSION}</small>"
	end
end
