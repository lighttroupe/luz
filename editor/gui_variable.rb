require 'gui_list_select'

class GuiVariable < GuiListSelect
	def list
		$engine.project.variables
	end
end
