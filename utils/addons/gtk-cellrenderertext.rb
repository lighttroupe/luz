class Gtk::CellRendererText
	def on_edited

		self.editable = true
		signal_connect('edited') { |renderer, path, value| yield path, value ; puts "edited callback: #{value}   " * 100 }
	end
end
