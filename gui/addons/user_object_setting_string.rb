multi_require 'gui_string'

class UserObjectSettingString
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiString.new(self, :string).set(:width => 20, :scale_x => 1.0, :float => :left, :scale_y => 0.5, :offset_y => 0.0)
		box
	end

	def string=(s)
		set(:string, s)			# this includes callbacks
	end
end
