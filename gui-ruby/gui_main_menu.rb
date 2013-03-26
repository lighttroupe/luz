class GuiMainMenu < GuiBox
	callback :close

	def initialize
		super
		create!
	end

	def create!
		self << GuiObject.new.set(:color => [0.5,0.5,0.5,0.5])
		self << @vbox = GuiVBox.new
		@vbox << @quit_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/menu.png'))
		@quit_button.on_clicked { $application.finished! }

		@vbox << @continue_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/play.png'))
		@continue_button.on_clicked { close_notify }
	end
end
