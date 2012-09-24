require 'gui_list_value'

class GuiActor < GuiListValue
	def list
		$engine.project.actors
	end
end
