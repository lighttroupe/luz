class UserObjectSettingSelect
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiSelect.new(self, :selected, @options[:options]).set(:scale_x => 1.0, :scale_y => 0.5, :offset_y => 0.25)
		box
	end
end
