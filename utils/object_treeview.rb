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

require 'smart_treeview', 'object_liststore'

class ObjectTreeView < SmartTreeView
	options :model_class => ObjectListStore

	# Returns iter of last row added.
	def set_objects(objects)
		model.clear
		add(objects)
	end

	def add(objects)
		model.add(objects)
	end

	def delete(object)
		model.delete(object)
	end

	def objects
		model.objects
	end

	# Selection
	def select(object)
		iter = model.find(object)
		super(iter) unless iter.nil?
	end

	def select_only(object)
		unselect_all
		select(object)
	end

	def add_and_select(objects)
		objects.to_a.each { |object| selection.select_iter(iter = add(object)) ; set_cursor(iter.path, nil, false) }
		grab_focus
	end

	# if after_object is nil, adds to end of list
	def add_after_and_select_only(objects, after_object=nil)
		after_iter = model.find(after_object)
		first = true
		selection.unselect_all
		objects.to_a.each { |object|	# NOTE: doing it in reverse puts final objects in correct order and leaves the top one selected
			if after_iter
				iter = model.insert_after(after_iter)
			else
				iter = model.append
			end
			model.set_object_column(iter, object)
			model.set_columns_from_object(iter)
			selection.select_iter(iter)
			set_cursor(iter.path, nil, false) if first
			first = false
			after_iter = iter
		}
		grab_focus
	end

	def add_and_select_only(objects)
		unselect_all
		add_and_select(objects)
	end

	def selected_each
		selection.selected_each { |_unused_model, _unused_path, iter| yield model.get_object_column(iter) }
	end

	def selected_each_update
		selection.selected_each { |_unused_model, _unused_path, iter|
			model.set_columns_from_object(iter) if yield model.get_object_column(iter)
		}
	end

	def visible_each
		first_path, last_path = visible_range
		while first_path and (iter = model.get_iter(first_path))
			yield iter
			first_path.next!
		end
	end

	def selected
		list = []
		selected_each { |obj| list << obj }
		return list
	end

	def update_selected
		selection.selected_each { |_unused_model, _unused_path, iter|
			model.set_columns_from_object(iter)
		}
	end

	def update_object(object)
		iter = model.find(object)
		model.set_columns_from_object(iter) unless iter.nil?
	end

	def update_all
		model.each_iter { |iter| model.set_columns_from_object(iter) }
	end

	def update_visible
		visible_each { |iter| model.set_columns_from_object(iter) }
	end

	def update_visible_if
		visible_each { |iter| model.set_columns_from_object(iter) if yield model.get_object_column(iter) }
	end

	def delete_selected
		# TODO: yes this is slow, but iterating/deleting on treeviews is hard :)
		selected.each { |obj| delete(obj) }
	end
end
