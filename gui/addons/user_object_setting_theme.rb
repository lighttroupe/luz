class UserObjectSettingTheme
	def gui_build_editor
		box = GuiBox.new
		box << GuiTheme.new(self, :theme).set(:scale_x => 0.25, :scale_y => 0.75, :float => :left, :offset_x => 0.02, :offset_y => -0.08)
		box << create_user_object_setting_name_label
		box
	end
end
