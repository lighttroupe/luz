class UserObjectSettingDirector
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiDirector.new(self, :director).set(:float => :left, :scale_x => 0.2, :scale_y => 0.9, :offset_y => -0.2, :item_aspect_ratio => 2.0)
		box << clear_button=GuiButton.new.set(:float => :left, :scale_x => 0.05, :scale_y => 0.8, :offset_y => -0.2, :background_image => $engine.load_image('images/buttons/clear.png'), :background_image_hover => $engine.load_image('images/buttons/clear-hover.png'), :background_image_click => $engine.load_image('images/buttons/clear-click.png'))
		clear_button.on_clicked {
			@director = nil
		}
		box
	end
end
