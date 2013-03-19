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

multi_require 'parent_user_object_editor_window', 'event', 'event_treeview', 'event_input', 'event_input_treeview', 'add_event_input_window'

class EventEditorWindow < ParentUserObjectEditorWindowWithDialogs
	alias :add_input_class :add_child_class

	UPDATE_INTERVAL = 0.25

	def initialize
		super('user_object_editor_window', Event, EventTreeView, UserObjectSettingsEditor, nil, EventInput, EventInputTreeView, UserObjectSettingsEditor, AddEventInputWindow)

		@last_update_time = 0.0
		@parent_treeview.model = $gui.event_model

		@child_editor.on_change { @child_treeview.update_selected } # Allow updating of preview
	end

	## Special add-variable behavior
	#def add_parent
		#add_parent_by_class(@parent_class)		# standard behavior
		##@parent_treeview.on_edit_properties		# new behavior: edit the name (TODO: do we want to do this?)
	#end

	def update
		@parent_treeview.update_visible_if { |obj| obj.changed? or obj.count_changed? }
		@child_treeview.update_visible_if { |obj| obj.changed? }
	end

private

	def on_parent_list_changed
		$engine.project.events = @parent_treeview.objects
	end
end
