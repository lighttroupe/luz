class Gtk::Table
	def add_row
		resize(n_rows + 1, n_columns)
		return n_rows - 1
	end
end

