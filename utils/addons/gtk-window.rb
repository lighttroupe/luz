class Gtk::Window
	def toggle_fullscreen
		@is_fullscreen = !@is_fullscreen
		fullscreen if @is_fullscreen
		unfullscreen if not @is_fullscreen
	end

	def toggle_visibility
		if visible?
			hide
		else
			present
		end
	end

	def on_lose_focus
		signal_connect('focus-out-event') { yield }
	end

	def present_modal
		self.modal = true
		present
	end

	def choose_file_save_path(title = 'Save File', filepath = nil, pattern = nil)
		dialog = Gtk::FileChooserDialog.new(title, self, Gtk::FileChooser::ACTION_SAVE, nil, [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL], [Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT])
		dialog.set_filter(Gtk::FileFilter.new.add_pattern(pattern)) if pattern

		if File.directory? filepath
			dialog.set_current_folder(filepath)
		elsif File.file? filepath
			dialog.set_filename(filepath)
		end

		dialog.set_do_overwrite_confirmation(true)
		if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
			filename = dialog.filename
			dialog.hide
			yield filename
		end
		dialog.destroy
	end

	def choose_file_open_path(title = 'Open File', directory = nil, pattern = nil)
		dialog = Gtk::FileChooserDialog.new(title, self, Gtk::FileChooser::ACTION_OPEN, nil, [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL], [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
		dialog.set_filter(Gtk::FileFilter.new.add_pattern(pattern)) if pattern
		dialog.set_current_folder(directory) if directory

		if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
			filename = dialog.filename
			dialog.hide
			yield filename
		end
		dialog.destroy
	end
end
