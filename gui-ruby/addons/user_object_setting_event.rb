class UserObjectSettingEvent
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiEvent.new(self, :event).set(:item_aspect_ratio => 5.0)
		box
	end
end
