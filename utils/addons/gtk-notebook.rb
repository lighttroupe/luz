class Gtk::Notebook
	def on_change
		signal_connect('switch-page') { |widget, page, page_number| yield page_number }
	end

	def on_change_with_init
		yield self.page		# yield once now to init
		on_change { |page_number| yield page_number }
	end
end
