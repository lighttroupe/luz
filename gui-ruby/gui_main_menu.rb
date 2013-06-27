class GuiMainMenu < GuiBox
	callback :save, :close

	def initialize
		super
		create!
	end

	def create!
		self << @cancel_button = GuiButton.new.set(:scale => 0.05, :offset_x => -0.475, :offset_y => 0.475, :background_image => $engine.load_image('images/buttons/close.png'))
		@cancel_button.on_clicked { close_notify }

		self << @save_button = GuiButton.new.set(:scale => 0.05, :offset_x => 0.475, :offset_y => 0.475, :background_image => $engine.load_image('images/buttons/save.png'))
		@save_button.on_clicked { save_notify ; close_notify }

		self << @quit_button = GuiButton.new.set(:scale => 0.05, :offset_x => -0.475, :offset_y => -0.475, :background_image => $engine.load_image('images/buttons/menu.png'))
		@quit_button.on_clicked { $application.finished! }
	end
end
