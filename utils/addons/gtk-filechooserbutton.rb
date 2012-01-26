class Gtk::FileChooserButton
	def on_change
		signal_connect('selection-changed') { yield }
	end
end
