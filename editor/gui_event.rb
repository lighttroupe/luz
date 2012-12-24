require 'gui_list_select'

class GuiEvent < GuiListSelect
	def list
		$engine.project.events
	end
end
