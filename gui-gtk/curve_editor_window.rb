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

require 'curve', 'curve_treeview', 'curve_editor', 'parent_user_object_editor_window_with_dialogs'

class CurveEditorWindow < ParentUserObjectEditorWindowWithDialogs
	pipe :set_parent_objects, :parent_treeview, :method => :set_objects
	empty_method :update_object, :update_all, :on_tag_selected

	def initialize
		super('user_object_editor_window',
			Curve, CurveTreeView, UserObjectSettingsEditor, nil,
			nil, nil, nil, nil)

		@child_container.hide

		@parent_editor = CurveEditor.new.set_visible(false)
		@editor_container_vbox.add(@parent_editor)
		@parent_editor.on_change { |vector, approximation|
			curve = @parent_treeview.selected.first
			curve.vector = vector
			curve.approximation = approximation
			@parent_treeview.update_object(curve)
			@parent_editor.update_object(curve)		# re-show curve, so user can see how Gtk::Curve mangled their work
		}
	end

	# Setting / Adding
	def add_parent
		add_parent_by_class(Curve)
	end

	empty_method :add_child

	# Callbacks
	def on_parent_selection_change
		@selected_parents = @parent_treeview.selected

		if @selected_parents.size == 1
			#	Show editor (and thus the GtkCurve) before setting vector to work around bug:
			#	https://bugs.launchpad.net/luz/+bug/134380
			@parent_editor.visible = true
			Gtk.main_clear_queue

			@parent_editor.create_for(@selected_parents.first)
		else
			@parent_editor.visible = false
		end
	end

	def on_parent_list_changed
		$engine.project.curves = @parent_treeview.objects
	end
end
