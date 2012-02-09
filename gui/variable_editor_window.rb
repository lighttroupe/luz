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

require 'parent_user_object_editor_window', 'variable', 'variable_treeview', 'variable_input', 'variable_input_treeview', 'add_variable_input_window'

class VariableEditorWindow < ParentUserObjectEditorWindowWithDialogs
	alias :add_input_class :add_child_class

	def initialize
		super('user_object_editor_window', Variable, VariableTreeView, UserObjectSettingsEditor, nil, VariableInput, VariableInputTreeView, UserObjectSettingsEditor, AddVariableInputWindow)

		@last_update_time = 0.0
		@parent_treeview.model = $gui.variable_model
	end

	# Special add-variable behavior
	def add_parent
		add_parent_by_class(@parent_class)		# standard behavior
		#@parent_treeview.on_edit_properties		# new behavior: edit the name (TODO: do we want to do this?)
	end

	def update
		@parent_treeview.update_visible_if { |obj| obj.changed? }
		@child_treeview.update_visible_if { |obj| obj.changed? }
		@child_editor.draw_update
	end

private

	def on_parent_list_changed
		$engine.project.variables = @parent_treeview.objects
	end
end
