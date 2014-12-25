class GuiThemeEditor < GuiBox
	def initialize
		super
		create!
	end

	def create!
		#self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/add-window-background.png')))

		self << (@list = GuiList.new.set({:offset_x => -0.45, :offset_y => 0.0, :scale_x => 0.1, :scale_y => 1.0, :spacing_y => -0.8, :item_aspect_ratio => 2.0}))
		self << (@list_scrollbar = GuiScrollbar.new(@list).set({:offset_x => -0.3885, :offset_y => 0.0, :scale_x => 0.025, :scale_y => 1.0}))
		@list.on_selection_change { on_list_selection_change }

		@list.contents = $engine.project.themes
	end
end