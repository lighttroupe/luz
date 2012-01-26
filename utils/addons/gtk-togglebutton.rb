class Gtk::ToggleButton
	def on_change_with_init
		yield		# yield once now to init
		on_change { yield }
	end

	def toggle
		set_active(!active?)
	end

	def on_change
		signal_connect('toggled') { yield }
	end
end
