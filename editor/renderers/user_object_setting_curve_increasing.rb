class UserObjectSettingCurveIncreasing
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiCurveIncreasing.new(self, :curve).set(:scale_x => 0.15, :scale_y => 0.4, :float => :left, :offset_x => 0.04, :offset_y => 0.14)
		box
	end
end
