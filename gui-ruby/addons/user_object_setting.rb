#
# Base class for all setting types (eg Float, Integer)
#
class UserObjectSetting
	include GuiPointerBehavior
	BACKGROUND_COLOR = [1,1,0,0.5]

	def gui_build_editor
		GuiObject.new.set(:color => [0,1,1,1])		# default render, just a "not implemented yet" debugging aid
	end

	def create_user_object_setting_name_label
		@name_label ||= BitmapFont.new.set(:color => [1.0,1.0,1.0,0.9], :string => name.gsub('_',' '), :scale_x => 1.0, :scale_y => 0.35, :offset_x => -0.02, :offset_y => 0.44, :color => [0.5,0.5,0])
	end
end
