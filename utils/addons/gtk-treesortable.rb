module Gtk::TreeSortable
	def sorted?
		sort_column_id != nil
	end
end
