class UserObjectSettingActor
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiActor.new(self, :actor)
		box
	end
end
