class Gtk::Container
	def add_tight(child)
		add(child)
		set_child_packing(child, expand=false, fill=false, padding=0, Gtk::PACK_START)
	end
end

