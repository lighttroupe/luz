require 'glade_window'

require 'ruby-git/lib/git'
require 'logger'

require 'object_liststore'
require 'object_treeview'

class GitCommitterWindow < GladeWindow
	def initialize(path)
		super('git_committer_window')
		@path = path

		create_treeview

		# TODO: create treeview
		open_repository
		add_changed_files
	end

	#
	# Gtk+ Callbacks
	#
	def on_pull_button_clicked
		@status_label.markup = sprintf("<span color='green'>%s</span>", 'Updating...')
		Gtk.main_clear_queue
		result_string = @git.pull
		@status_label.markup = sprintf("<span color='green'>%s</span>", result_string)
		# git pull --rebase
	end

	def on_commit_button_clicked
		#@git.add([file1, file2])
		#@git.commit('message')
	end

	def on_push_button_clicked
		# @git.push
	end

	def on_delete_event
		Gtk.main_quit		# quit app when main window is closed
	end

private

	#
	# ModifiedFilesTreeView
	#
	class ModifiedFilesTreeView < ObjectTreeView
		column :path, :title => 'File', :renderers => [{:type => :text, :model_column => :path}]

		def initialize(model)
			super(:model => model)
			self.rules_hint = true
			self.headers_visible = false
		end
	end

	#
	# ModifiedFilesListStore
	#
	class ModifiedFilesListStore < ObjectListStore
		column :path, :type => :text, :from_object => Proc.new { |object| object.path }		# object is [path, Git::Status]
	end

	#
	#
	#
	def create_treeview
		@modified_files_model = ModifiedFilesListStore.new
		@modified_files_treeview = ModifiedFilesTreeView.new(@modified_files_model)
		@modified_files_model.set_sort_column_id(ModifiedFilesListStore.path_column_index)
		@list_container.add(@modified_files_treeview)
		@modified_files_treeview.grab_focus
	end

	def open_repository
		@git = Git.open(@path, :log => Logger.new(STDOUT))
	end

	def add_changed_files
		@git.status.changed.each { |file|
			@modified_files_model.add([file.last])
		}
	end
end
