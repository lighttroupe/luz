#
# Base class for all setting types (eg Float, Integer)
#
class UserObjectSetting
	include GuiPointerBehavior
	BACKGROUND_COLOR = [1,1,0,0.5]
	NOT_IMPLEMENTED_COLOR = [1,0,1,1]

	def gui_build_editor
		GuiObject.new.set(:color => NOT_IMPLEMENTED_COLOR)		# override
	end

	def create_user_object_setting_name_label
		@name_label ||= GuiLabel.new.set(:width => 15, :string => name.gsub('_',' '), :color => [1.0,1.0,1.0,1.0], :scale_x => 0.5, :scale_y => 0.35, :offset_x => -0.25, :offset_y => 0.5)
	end
end
