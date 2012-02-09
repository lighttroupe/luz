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

require 'object_treeview', 'user_object_class_liststore'

class UserObjectClassTreeView < ObjectTreeView
	column :title, :renderers => [{:type => :markup, :model_column => :title}]
	options :model_class => UserObjectClassListStore, :headers_visible => false

	def initialize
		super
		model.set_sort_column_id(UserObjectClassListStore.title_column_index)
	end

	def add(klass)
		super(klass) unless klass.virtual?
	end
end

