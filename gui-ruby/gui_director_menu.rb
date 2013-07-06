class GuiDirectorMenu < GuiBox
	def initialize(contents)
		super()
		create!
		@grid.contents = contents
	end

	def create!
		self << @background = GuiObject.new.set(:background_image => $engine.load_image('images/overlay.png'))

		self << @grid = GuiGrid.new.set(:scale => 0.95, :spacing_x => 0.1, :spacing_y => 0.1)

		self << @add_button = GuiButton.new.set(:scale => 0.05, :offset_x => -0.475, :offset_y => -0.475, :background_image => $engine.load_image('images/buttons/add.png'))
		@add_button.on_clicked {
			add_new_director!
		}

		self << @cancel_button = GuiButton.new.set(:scale => 0.05, :offset_x => 0.475, :offset_y => 0.475, :background_image => $engine.load_image('images/buttons/close.png'))
		@cancel_button.on_clicked {
			$gui.build_editor_for($gui.chosen_director)
		}
	end

	def add_new_director!
		director = Director.new
		@grid << director
		$gui.build_editor_for(director)
		switch_state({:open => :closed}, duration=0.5)
	end
end
