class Gtk::ComboBox
	def on_change_with_init
		yield		# yield once now to init
		on_change { yield }
	end

	def each_iter
		model.each {|model, path, iter| yield iter }
	end

	def select_first
		self.active_iter = model.iter_first
	end

	def select_none
		self.active = -1
	end

	def on_change
		signal_connect('changed') { yield }
	end
end
