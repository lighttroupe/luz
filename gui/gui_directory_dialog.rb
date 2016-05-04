class GuiDirectoryDialog < GuiFileDialog
	def initialize(title)
		super(title, nil)
	end

	def create!
		super
		@open_button.on_clicked { selected_notify(@path) }
	end

private

	def load_files
		[]		# we don't show files
	end
end
