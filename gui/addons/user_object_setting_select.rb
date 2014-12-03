class UserObjectSettingSelect
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiSelect.new(self, :selected, @options[:options]).set(:scale_x => 0.3, :scale_y => 0.5, :offset_x => -0.5 + 0.15, :offset_y => 0.1)
		box
	end
end
