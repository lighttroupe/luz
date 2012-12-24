require 'gui_list_select'

class GuiCurveIncreasing < GuiListSelect
	def list
		$engine.project.curves.select { |c| c.up? }
	end
end
