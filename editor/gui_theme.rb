require 'gui_list_select'

class GuiTheme < GuiListSelect
	def list
		$engine.project.themes
	end
end
