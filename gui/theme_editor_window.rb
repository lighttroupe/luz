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

require 'parent_user_object_editor_window', 'theme', 'theme_treeview', 'style', 'style_treeview'

class ThemeEditorWindow < ParentUserObjectEditorWindow
	def initialize
		super('user_object_editor_window',
			Theme, ThemeTreeView, UserObjectSettingsEditor,
			Style, StyleTreeView, UserObjectSettingsEditor,
			$gui.theme_tag_model)

		@parent_treeview.model = $gui.theme_model

		@child_editor.on_change { @parent_treeview.update_selected }
	end

private

	def on_parent_list_changed
		super
		$engine.project.themes = @parent_treeview.objects
	end

	def on_child_list_changed
		super
		@parent_treeview.update_selected
	end
end
