require 'gui_list_value'

class GuiVariable < GuiListValue
	def list
		$engine.project.variables
	end
end
