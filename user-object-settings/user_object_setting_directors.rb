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

require 'user_object_setting'

class UserObjectSettingDirectors < UserObjectSetting
	def to_yaml_properties
		super + ['@tag']
	end

	def widget
		create_director_tag_combobox(:tag)
	end

	def one(index=0)
		list = Director.with_tag(@tag)
		return nil if list.empty?		# NOTE: return without yielding

		selection = list[index % list.size]		# NOTE: nicely wraps around at both edges
		yield selection if block_given?
		return selection
	end

	def count
		Director.with_tag(@tag).size
	end

	def each
		Director.with_tag(@tag).each { |director| yield director }
	end

	def all
		yield Director.with_tag(@tag)
	end
end
