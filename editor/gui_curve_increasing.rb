require 'gui_list_value'

class GuiCurveIncreasing < GuiListValue
	def list
		$engine.project.curves.select { |c| c.up? }
	end
end
