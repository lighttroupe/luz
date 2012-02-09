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

require 'object_treeview', 'user_object_liststore'

class UserObjectTreeView < ObjectTreeView
	options :model_class => UserObjectListStore, :headers_visible => false

	column :title, :renderers => [{:name => :title, :type => :markup, :model_column => :title, :options => {:ellipsize => Pango::ELLIPSIZE_END}}], :expand => true
	column :enabled, :renderers => [{:type => :toggle, :model_column => :enabled, :on_toggled => :on_toggled}]

	def initialize(options={})
		super(options)

		# Custom search function (NOTE: that we must return 'false' for matches)
		set_search_equal_func { |model, columnm, key, iter| !model.get_object_column(iter).text_match?(key) }

		self.rules_hint = true
	end

	def selected_toggle_enabled
		selection.selected_each { |_unused_model, _unused_path, iter| on_toggled(iter) }
	end

	def on_toggled(iter)
		model.get_object_column(iter).toggle_enabled
		model.set_columns_from_object(iter)
		$engine.project_changed!
	end

	def swap_tag_ordering_for_iters(iter_a, iter_b)
		object_a = model.get_object_column(iter_a)
		object_b = model.get_object_column(iter_b)

		if object_a.respond_to? :tags
			#
			# For each tag that both objects share, help the tagging feature by
			# notifying it of the change in ordering
			#
			(object_a.tags & object_b.tags).each { |overlap_tag|
				object_a.class.swap_tagged_objects(overlap_tag, object_a, object_b)
			}
		end
	end

	#
	# override move_after and move_before (used in drag-n-drop) to properly notify tag system
	#
	def move_after(iter_to_move, after_iter)
		super
		swap_tag_ordering_for_iters(iter_to_move, after_iter)		# NOTE: assumes above swap was necessary
	end

	def move_before(iter_to_move, before_iter)
		super
		swap_tag_ordering_for_iters(iter_to_move, before_iter)		# NOTE: assumes above swap was necessary
	end
end
