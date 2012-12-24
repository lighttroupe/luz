require 'gui_list_select'

class GuiActor < GuiListSelect
	def list
		$engine.project.actors
	end
end
