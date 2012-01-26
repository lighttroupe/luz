class Gtk::SpinButton
	def on_change
		signal_connect('value-changed') { yield }
	end
end
