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

require 'parent_user_object_editor_window'

class ParentUserObjectEditorWindowWithDialogs < ParentUserObjectEditorWindow
	def initialize(glade_root, parent_class, parent_treeview_class, parent_editor_class, parent_add_dialog_class, child_class, child_treeview_class, child_editor_class, child_add_dialog_class, tag_model=nil)
		super(glade_root, parent_class, parent_treeview_class, parent_editor_class, child_class, child_treeview_class, child_editor_class, tag_model)

		###################################################################
		# Add Parent Dialog
		###################################################################
		if parent_add_dialog_class
			@add_parent_window = parent_add_dialog_class.new
			@add_parent_window.on_add { |klass|
				object = add_parent_by_class(klass)
				@saved_add_proc.call(object) if @saved_add_proc
				@saved_add_proc = nil
			}
		end

		###################################################################
		# Add Child Dialog
		###################################################################
		if child_add_dialog_class
			@add_child_window = child_add_dialog_class.new
			@add_child_window.on_add { |klass| add_child_by_class(klass) }
		end
	end

	def add_parent
		if @add_parent_window
			@add_parent_window.present
		else
			add_parent_by_class(@parent_class)
		end
	end

	def yield_new_parent_object(&proc)
		if @add_parent_window
			@saved_add_proc = proc
			@add_parent_window.present
		else
			yield add_parent_by_class(@parent_class)
		end
	end

	# NOTE: add similar method for add_child if we ever need a parent-with-dialog, child-without situation
	def add_child
		@add_child_window.show_for(@selected_parents) unless @selected_parents.empty?
	end
end
