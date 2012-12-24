require 'gui_list_select'

class GuiCurve < GuiListSelect
	def list
		$engine.project.curves
	end
end
