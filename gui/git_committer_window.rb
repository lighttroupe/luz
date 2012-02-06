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
		on_selected_files_changed
		@commit_message_entry.on_change { on_selected_files_changed }
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
		@git.add(@modified_files_treeview.selected_files.map { |file| file.path } )
		@git.commit(commit_message)
	end

	def on_push_button_clicked
		# @git.push
	end

	def on_delete_event
		Gtk.main_quit		# quit app when main window is closed
	end
	
	def commit_message
		@commit_message_entry.text.strip
	end

	def on_selected_files_changed
		list = @modified_files_treeview.selected_files
		count = list.count
		@commit_button.sensitive = (count > 0 and not commit_message.empty?)
		@commit_button.label = sprintf("Commit %d", count)
	end
	
	def unpushed_commits?
		
	end

private

	#
	# ModifiedFilesTreeView
	#
	class ModifiedFilesTreeView < ObjectTreeView
		column :path, :title => 'File', :renderers => [{:type => :text, :model_column => :path}], :expand => true
		column :selected, :renderers => [{:type => :toggle, :model_column => :selected, :on_toggled => :on_toggled}], :position => :start

		callback :selected_files_changed
		attr_reader :selected_files

		def initialize(model)
			super(:model => model)

			@selected_files = []

			# Cosmetic changes
			self.rules_hint = true
			self.headers_visible = false
		end

		def on_toggled(iter)
			if model.get_selected_column(iter) == 0
				# was off, add it
				@selected_files << model.get_object_column(iter)
				model.set_selected_column(iter, 1)
			else
				# was on, remove it
				@selected_files.delete(model.get_object_column(iter))
				model.set_selected_column(iter, 0)
			end
			selected_files_changed_notify
		end
	end

	#
	# ModifiedFilesListStore
	#
	class ModifiedFilesListStore < ObjectListStore
		column :selected, :type => :integer, :from_object => Proc.new { |object| 0 }
		column :path, :type => :text, :from_object => Proc.new { |object| object.path }		# object is [path, Git::Status]

		def initialize(parent)
			@parent = parent
			super()
		end
	end

	#
	#
	#
	def create_treeview
		@modified_files_model = ModifiedFilesListStore.new(self)
		@modified_files_treeview = ModifiedFilesTreeView.new(@modified_files_model)

		@modified_files_treeview.on_selected_files_changed { on_selected_files_changed }

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
