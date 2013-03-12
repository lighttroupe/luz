 ###############################################################################
 #  Copyright 2008 Ian McIntosh <ian@openanswers.org>
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

require 'callbacks'

class History
	callback :navigation

	def initialize
		@list = []
		@index = -1
	end

	#
	# Status
	#
	def can_go_back?
		@index > 0
	end

	def current?
		@index > -1
	end

	def current
		@list[@index] if current?
	end

	def can_go_forward?
		@index < (@list.size - 1)
	end

	#
	# Navigation
	#
	def back!
		if can_go_back?
			@index -= 1
			navigation_notify(current)
			true
		end
	end

	def forward!
		if can_go_forward?
			@index += 1
			navigation_notify(current)
			true
		end
	end

	#
	# Manipulation
	#
	def add(item)
		@index += 1
		@list[@index] = item
		@list = @list.first(@index+1)		# chop off all history after this index
	end

	def remove(item)
		return unless (index = @list.index(item))
		@index -= 1 if index <= @index
		@list.delete(item)
	end
end
