class UserObjectSettingFont
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiFontSelect.new(self, :font).set(:scale_x => 0.5, :offset_x => -0.25, :scale_y => 0.5, :offset_y => 0.25, :item_aspect_ratio => 6.0)
		box
	end
end
