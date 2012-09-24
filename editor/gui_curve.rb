require 'gui_list_value'

class GuiCurve < GuiListValue
	def list
		$engine.project.curves
	end
end
