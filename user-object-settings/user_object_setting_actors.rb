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

class UserObjectSettingActors < UserObjectSetting
	def to_yaml_properties
		super + ['@tag']
	end

	def after_load
		set_default_instance_variables(:tag => nil)
		super
	end

	def widget
		create_actor_tag_combobox(:tag)
	end

	#
	# API for plugins
	#
	def one(index=0)
		list = Actor.with_tag(@tag)
		return nil if list.empty?		# NOTE: return without yielding

		selection = list[index % list.size]		# NOTE: nicely wraps around at both edges
		yield selection if block_given?
		return selection
	end

	def count
		Actor.with_tag(@tag).size
	end

	def each
		Actor.with_tag(@tag).each { |actor| yield actor }
	end

	def each_with_index
		Actor.with_tag(@tag).each_with_index { |actor, index| yield actor, index }
	end

	def all
		yield Actor.with_tag(@tag)
	end
end
