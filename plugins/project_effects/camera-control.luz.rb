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

class ProjectEffectCameraControl < ProjectEffect
	title				"Camera"
	description "Sets position and roll, pitch, yaw control of camera."

	hint "Place this before drawing Directors."

	setting 'x', :float, :default => 0.0..1.0
	setting 'y', :float, :default => 0.0..1.0
	setting 'z', :float, :default => 0.0..1.0
	setting 'roll', :float, :default => 0.0..1.0
	setting 'pitch', :float, :default => 0.0..1.0
	setting 'yaw', :float, :default => 0.0..1.0

	def render
		GL.MatrixMode(GL::PROJECTION)
		GLU.LookAt(
			x, y, -z,
			x + (fuzzy_sine(-yaw + 0.5) - 0.5), y + (fuzzy_sine(-pitch + 0.5) - 0.5), -1, 		# TODO: look at appropriate point
			0, 1, 0) 		# up vector positive Y up vector

		with_roll(-roll) {
			GL.MatrixMode(GL::MODELVIEW)
			yield
			GL.MatrixMode(GL::PROJECTION)
		}
		GL.MatrixMode(GL::MODELVIEW)
	end
end
