require 'glade_window'

class GitCommitterWindow < GladeWindow
	def initialize(path)
		super('git_committer_window')
		@path = path
		
		# TODO: create treeview

		add_changed_files
	end

	def add_changed_files
		# TODO
	end

	#
	# Callbacks
	#
	def on_delete_event
		Gtk.main_quit		# quit app when main window is closed
	end
end
