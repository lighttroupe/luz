multi_require 'gui_list_select'

class GuiCurveIncreasing < GuiListSelect
	def list
		$engine.project.curves.select { |c| c.up? }.map { |theme| GuiObjectRenderer.new(theme) }
	end

	def set_value(value)
		super(value.object)
	end
end
