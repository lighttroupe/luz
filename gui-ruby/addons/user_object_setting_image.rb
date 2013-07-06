class UserObjectSettingImage
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiString.new(self, :image_name).set(:scale_x => 0.5, :float => :left, :scale_y => 0.5, :offset_y => 0.0)
		box
	end
end

