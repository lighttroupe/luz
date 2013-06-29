class UserObjectSettingSlider
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiEngineSlider.new(self, :slider).set(:scale_x => 0.5, :float => :left, :scale_y => 0.5, :offset_y => 0.0, :item_aspect_ratio => 6.0)
		box
	end
end
