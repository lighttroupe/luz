class Gtk::Button
	def on_click
		signal_connect('clicked') { yield }
	end
end
