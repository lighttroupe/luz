class Gtk::CellRendererToggle
	def on_toggled
		signal_connect('toggled') { |renderer, path| yield path }
	end
end
