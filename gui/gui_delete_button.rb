class GuiDeleteButton < GuiBox
	callback :clicked

	def initialize(*args)
		super
		create!
	end

	def create!
		self << @button = GuiButton.new.set(:offset_x => 0.25, :scale_x => 0.5, :opacity => 0.5, :background_image => $engine.load_image('images/buttons/delete.png'))
		self << @cover = GuiButton.new.set(:scale_x => 0.5, :opacity => 0.5, :background_image => $engine.load_image('images/buttons/delete-cover.png')).
						add_state(:open, :offset_x => -0.25).
						set_state(:closed, :offset_x => 0.25)

		@button.on_clicked {
			clicked_notify
		}
		@cover.on_clicked {
			@cover.switch_state({:closed => :open, :open => :closed}, duration=0.2)
		}
	end
end

