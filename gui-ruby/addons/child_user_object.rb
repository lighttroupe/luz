#
# Addons for base class of all "effects" of UserObjects 
#
class ChildUserObject < UserObject
	#
	# Rendering
	#
	def self.gui_render!
		gui_render_label
	end

	def enable_checkbox
		@enable_checkbox ||= GuiToggle.new(self, :enabled).set(:offset_x => 0.45, :offset_y => 0.0, :scale_x => 0.09, :scale_y => 0.9)
	end

	def gui_render!
		gui_render_background
		gui_render_label
		enable_checkbox.gui_render!
	end

	def hit_test_render!
		super
		enable_checkbox.hit_test_render!
	end

	def label_color
		if crashy?
			LABEL_COLOR_CRASHY
		elsif !enabled?
			LABEL_COLOR_DISABLED
		elsif conditions.enable_event? && !conditions.event.now?
			LABEL_COLOR_CONDITIONS_UNMET
		else
			LABEL_COLOR
		end
	end
end
