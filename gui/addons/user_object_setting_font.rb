class UserObjectSettingFont
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiSelect.new(self, :selected, options).set(:scale_x => 1.0, :scale_y => 0.5, :offset_y => 0.25)
		box
	end

private

	def options
		#@context ||= Pango::Context.new
		#p @context.families
		[[:one, 'Font One'], [:one, 'Font Two']]
	end
end
