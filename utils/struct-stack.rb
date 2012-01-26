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

# reuses structs to prevent garbage production
class StructStack
	def initialize(klass)
		@class = klass
	end

	def pop(*args)
		@available_stack ||= []
		@used_hash ||= {}

		if @available_stack.empty?
			obj = @class.new(*args)
		else
			obj = @available_stack.pop
			args.each_with_index { |arg, i| obj[i] = arg }
		end
		@used_hash[obj] = true
		return obj
	end

	def push(obj)
		@available_stack << obj
		@used_hash.delete(obj)
	end
end
