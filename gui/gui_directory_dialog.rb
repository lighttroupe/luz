class GuiDirectoryDialog < GuiFileDialog
	def initialize(title)
		super(title, nil)
	end

	def create!
		self << (@overlay = GuiObject.new.set(:background_image => $engine.load_image('images/file-dialog-background.png')))

		self << (@background = GuiObject.new.set(:scale_x => 0.3, :color => [0,0,0]))

		self << (@title_label = GuiLabel.new.set({:width => 20, :text_align => :center, :color => [0.6,0.6,1.0], :string => @title, :offset_x => 0.0, :offset_y => 0.47, :scale_x => 0.3, :scale_y => 0.05}))

		self << (@up_button=GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.07, :offset_x => -0.17, :offset_y => 0.5 - 0.23, :background_image => $engine.load_image('images/buttons/directory-up.png'), :background_image_hover => $engine.load_image('images/buttons/directory-up-hover.png')))
		@up_button.on_clicked { show_for_path(File.join(@path, '..')) }

		self << (@path_label = GuiLabel.new.set(:width => 40, :text_align => :center, :color => [1.0,1.0,1.0], :scale_x => 0.7, :scale_y => 0.04, :offset_y => 0.5 - 0.08))

		self << (@open_button = GuiLabel.new.set({:width => 14, :color => [0.2,0.8,0.2], :string => 'choose this directory', :offset_x => 0.0, :offset_y => 0.5 - 0.13, :scale_x => 0.20, :scale_y => 0.05}))

		self << (@directory_list = GuiList.new.set(:scale_x => 0.25, :scale_y => 0.825, :offset_x => 0.0, :offset_y => -0.1, :spacing_y => -1.0, :item_aspect_ratio => 8.0))

		self << (@close_button=GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => 0.475, :offset_y => 0.47, :background_image => $engine.load_image('images/buttons/file-dialog-cancel.png'), :background_image_hover => $engine.load_image('images/buttons/file-dialog-cancel-hover.png'), :background_image_click => $engine.load_image('images/buttons/file-dialog-cancel-click.png')))
		@close_button.on_clicked { closed_notify }

		@open_button.on_clicked { selected_notify(@path) }

		# focus
		#@directory_list.grab_keyboard_focus!
	end

	def load_files
		[]		# we don't show files
	end
end
