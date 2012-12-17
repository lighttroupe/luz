class UserObjectSettingEvent
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiEvent.new(self, :event)
		box
	end
end
