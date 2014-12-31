class UserObjectSettingSelect
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiSelect.new(self, :selected, @options[:options]).set(:width => 20, :scale_x => 0.5, :scale_y => 0.45, :float => :left, :offset_y => 0.1)
		box
	end
end
