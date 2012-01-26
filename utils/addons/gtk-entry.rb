class Gtk::Entry
	def on_change
		signal_connect('changed') { yield }
	end
end
