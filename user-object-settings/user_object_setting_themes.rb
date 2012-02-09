 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
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

# Actor factory
# -> Sometimes you want one
# -> Sometimes you want one by tag (by index)
# -> Sometimes you want all by tag

class UserObjectSettingThemes < UserObjectSetting
	def to_yaml_properties
		super + ['@tag']
	end

	def widget
		create_theme_tag_combobox(:tag)
	end

	#
	# API for plugins
	#
	def one(index=0)
		list = Theme.with_tag(@tag)
		yield list[index % list.size] unless list.empty?		# NOTE: wraps around to 0, is this the right behavior?
	end

	def count
		Theme.with_tag(@tag).size
	end

	def each
		Theme.with_tag(@tag).each { |theme| yield theme }
	end

	def all
		yield Theme.with_tag(@tag)
	end
end
