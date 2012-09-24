require 'gui_list_value'

class GuiTheme < GuiListValue
	def list
		$engine.project.themes
	end
end
