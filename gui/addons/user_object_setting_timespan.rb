class UserObjectSettingTimespan
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiFloat.new(self, :time_number, 0.0, 999.0, digits=2).set(:float => :left, :scale_x => 0.20, :scale_y => 0.5)
		box << GuiSelect.new(self, :time_unit, TIME_UNIT_OPTIONS).set(:float => :left, :scale_x => 0.25, :scale_y => 0.5)
		box
	end
end
