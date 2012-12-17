class UserObjectSettingVariable
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiVariable.new(self, :variable)
		box
	end
end
