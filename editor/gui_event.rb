require 'gui_list_value'

class GuiEvent < GuiListValue
	def list
		$engine.project.events
	end
end
