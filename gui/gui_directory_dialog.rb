class GuiDirectoryDialog < GuiFileDialog
	def initialize(title)
		super(title, nil)
	end

	def create!
		super
		self << (@open_button = GuiLabel.new.set({:width => 10, :color => [0.6,0.6,1.0], :string => 'Select', :offset_x => 0.0, :offset_y => -0.47, :scale_x => 0.15, :scale_y => 0.05}))
		@open_button.on_clicked { selected_notify(@path) }
	end

private

	def load_files
		[]		# we don't show files
	end
end
