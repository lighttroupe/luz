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

class ProjectEffectReloadCode < ProjectEffect
	title				"Reload Code"
	description "Reloads the source code off disk.  For developers."

	setting 'reload', :event, :summary => 'on %'

	def tick
		if reload.on_this_frame?
			change_count = $engine.reload
			$gui.reload_notify
			if change_count > 0
				$gui.positive_message "Reloaded #{change_count.plural('file', 'files')}."
			else
				$gui.positive_message "No modified source files found."
			end
		end
	end
end
