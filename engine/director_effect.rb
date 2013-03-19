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

multi_require 'child_user_object', 'drawing'

class DirectorEffect < ChildUserObject
	include Drawing

	attr_accessor :director, :layer_index, :total_layers		# set just before render time

	###################################################################
	# Object-level functions
	###################################################################
	def after_load
		set_default_instance_variables(:enabled => true)
		super
	end

	# default implementation just yields once (renders scene once)
	def render
		yield
	end
end
