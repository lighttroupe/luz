class GuiMainMenu < GuiBox
	callback :save, :close, :open

	def initialize
		super
		create!
	end

	def create!
		self << @cancel_button = GuiButton.new.set(:scale => 0.05, :offset_x => -0.475, :offset_y => 0.475, :background_image => $engine.load_image('images/buttons/main-menu-close.png'))
		@cancel_button.on_clicked { close_notify }

		self << @open_button = GuiButton.new.set(:scale => 0.05, :offset_x => 0.475, :offset_y => 0.475, :background_image => $engine.load_image('images/buttons/main-menu-open.png'))
		@open_button.on_clicked { open_notify }

		self << @save_button = GuiButton.new.set(:scale => 0.05, :offset_x => 0.475, :offset_y => -0.475, :background_image => $engine.load_image('images/buttons/main-menu-save.png'))
		@save_button.on_clicked { save_notify ; close_notify }

		self << @quit_button = GuiButton.new.set(:scale => 0.05, :offset_x => -0.475, :offset_y => -0.475, :background_image => $engine.load_image('images/buttons/main-menu-quit.png'))
		@quit_button.on_clicked { $application.finished! }
	end
end
