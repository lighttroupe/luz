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

require 'object_treeview'

class TagTreeView < ObjectTreeView
	column :name, :type => :text, :title => 'Tag', :renderers => [{:type => :text, :model_column => :name}], :expand => true
	column :enabled, :type => :toggle, :title => '', :renderers => [{:type => :toggle, :model_column => :activated, :model_column_inconsistent => :inconsistent, :on_toggled => :toggled_notify}]

	options :enable_search => true, :headers_visible => false

	callback :toggled

	def initialize(model)
		super :model => model

		model.set_sort_column_id(model.class.name_column_index)
		on_key_press(Gdk::Keyval::GDK_space) { selected_toggle_enabled ; true }
	end

	def selected_toggle_enabled
		selection.each_iter { |iter| toggled_notify(iter) }
	end
end
