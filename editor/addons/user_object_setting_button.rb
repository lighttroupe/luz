class UserObjectSettingButton
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiEngineButton.new(self, :button).set(:scale_y => 0.5)
		box
	end
end
