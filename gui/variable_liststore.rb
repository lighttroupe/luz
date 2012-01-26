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

require 'parent_user_object_liststore'

class VariableListStore < ParentUserObjectListStore
	column :progress, :type => :integer, :from_object => Proc.new { |object| display_value_for(object.do_value) }		# NOTE: using ceil prevents non-0.0 from showing as 0%

	def self.display_value_for(value)
		# convert 0.0..1.0 to 0.0..100.0 and prevent non-0.0 and non-1.0 from showing as such
		return 1.0 if value > 0.0 and value <= 0.01
		return 99.0 if value > 0.99 and value < 1.0
		return (value * 100.0).ceil
	end
end
