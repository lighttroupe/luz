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

class ProjectEffectReloadOnEvent < ProjectEffect
	virtual		# deprecated

	title				"Reload on Event"
	description "Reloads the Luz project off disk."

	setting 'reload', :event, :summary => 'on %'

	def render
		if $gui
			yield
		elsif reload.on_this_frame?
			puts 'Reloading project!'
			path = $engine.project.path
			$engine.load_from_path(path)

			# does not yield -- no point in continuing this frame
		else
			yield		# fullscreen normal case
		end
	end
end
