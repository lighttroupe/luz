class Gtk::TextView
	def text
		buffer.text
	end

	def text=(rhs)
		buffer.text = rhs
	end

	def on_change
		buffer.signal_connect('changed') { yield }
	end
end
