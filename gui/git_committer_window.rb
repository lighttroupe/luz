require 'glade_window'

require 'ruby-git/lib/git'

class GitCommitterWindow < GladeWindow
	def initialize(path)
		super('git_committer_window')
		@path = path
		
		# TODO: create treeview

		add_changed_files
	end

	#
	# Gtk+ Callbacks
	#
	def on_pull_button_clicked
		# git pull --rebase
	end

	def on_commit_button_clicked
		# git commit <files> -m <message>
	end

	def on_push_button_clicked
		# git push
	end

	def on_delete_event
		Gtk.main_quit		# quit app when main window is closed
	end

private

	def add_changed_files
		# TODO
	end
end
