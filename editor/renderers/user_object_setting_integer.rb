class UserObjectSettingInteger
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiInteger.new(self, :animation_min, @min, @max).set(:scale_x => 0.3, :float => :left, :scale_y => 0.5, :offset_y => 0.25)
		box
	end
end

